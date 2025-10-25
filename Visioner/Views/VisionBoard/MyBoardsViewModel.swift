//
//  MyBoardsViewModel.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import CoreData
import Combine

/// ViewModel for managing saved vision boards
final class MyBoardsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var boards: [VisionBoardEntity] = []
    @Published var isLoading = false
    @Published var selectedBoard: VisionBoardEntity?
    @Published var showingDeleteAlert = false
    @Published var boardToDelete: VisionBoardEntity?
    @Published var showingExportProgress = false
    @Published var exportProgress: Double = 0.0
    
    // MARK: - Private Properties
    
    private let visionBoardService = VisionBoardService.shared
    private let templateManager = TemplateManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        loadBoards()
    }
    
    // MARK: - Public Methods
    
    /// Load all saved boards from Core Data
    func loadBoards() {
        isLoading = true
        
        // Fetch all boards from Core Data
        let fetchRequest: NSFetchRequest<VisionBoardEntity> = VisionBoardEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \VisionBoardEntity.createdDate, ascending: false)]
        
        do {
            let context = PersistenceController.shared.container.viewContext
            boards = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch boards: \(error)")
            boards = []
        }
        
        isLoading = false
    }
    
    /// Duplicate a board
    func duplicateBoard(_ board: VisionBoardEntity) {
        guard let template = templateManager.templates.first(where: { $0.id == board.templateId }) else {
            print("Template not found for board: \(board.templateId ?? "unknown")")
            return
        }
        
        let newBoard = visionBoardService.createBoard(
            from: template,
            title: "\(board.title ?? "Vision Board") Copy"
        )
        
        // Copy slot content
        for (index, originalSlot) in board.slotsArray.enumerated() {
            if index < newBoard.slotsArray.count {
                let newSlot = newBoard.slotsArray[index]
                newSlot.imageData = originalSlot.imageData
                newSlot.text = originalSlot.text
                newSlot.fontName = originalSlot.fontName
                newSlot.fontSize = originalSlot.fontSize
                newSlot.colorHex = originalSlot.colorHex
            }
        }
        
        // Refresh the boards list
        loadBoards()
        
        // Haptic feedback
        HapticFeedbackService.shared.provideFeedback(.success)
    }
    
    /// Delete a board
    func deleteBoard(_ board: VisionBoardEntity) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(board)
        
        do {
            try context.save()
            loadBoards()
            
            // Haptic feedback
            HapticFeedbackService.shared.provideFeedback(.impact)
        } catch {
            print("Failed to delete board: \(error)")
        }
    }
    
    /// Export a board
    func exportBoard(_ board: VisionBoardEntity) async {
        guard let template = templateManager.templates.first(where: { $0.id == board.templateId }) else {
            print("Template not found for board: \(board.templateId ?? "unknown")")
            return
        }
        
        await MainActor.run {
            showingExportProgress = true
            exportProgress = 0.0
        }
        
        // Export the board
        let image = await BoardExportService.shared.exportBoard(board, template: template)
        
        if let image = image {
            // Save to Photos
            let saved = await BoardExportService.shared.saveToPhotos(image)
            
            await MainActor.run {
                showingExportProgress = false
                exportProgress = 1.0
            }
            
            if !saved {
                // Handle export failure
                print("Failed to save board to Photos")
            }
        } else {
            await MainActor.run {
                showingExportProgress = false
            }
        }
    }
    
    /// Get template for a board
    func getTemplate(for board: VisionBoardEntity) -> VisionBoardTemplate? {
        return templateManager.templates.first { $0.id == board.templateId }
    }
    
    /// Get board creation date as formatted string
    func formattedDate(for board: VisionBoardEntity) -> String {
        guard let date = board.createdDate else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Get board completion percentage
    func completionPercentage(for board: VisionBoardEntity) -> Double {
        let totalSlots = board.slotsArray.count
        guard totalSlots > 0 else { return 0.0 }
        
        let filledSlots = board.slotsArray.filter { slot in
            slot.imageData != nil || (slot.text != nil && !slot.text!.isEmpty && slot.text != "+ Write affirmation")
        }.count
        
        return Double(filledSlots) / Double(totalSlots)
    }
}
