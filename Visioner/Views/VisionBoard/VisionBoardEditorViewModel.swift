//
//  VisionBoardEditorViewModel.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import PhotosUI
import Combine
import CoreData

/// ViewModel for the vision board editor screen
final class VisionBoardEditorViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var board: VisionBoardEntity
    @Published var selectedSlotId: Int?
    @Published var showingBottomSheet = false
    @Published var editingText = ""
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var isSaving = false
    
    // MARK: - Private Properties
    
    private let visionBoardService = VisionBoardService.shared
    let template: VisionBoardTemplate
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var selectedSlot: SlotContentEntity? {
        guard let selectedSlotId = selectedSlotId else { return nil }
        return board.slotsArray.first { $0.id == selectedSlotId }
    }
    
    var selectedSlotTemplate: VisionSlotTemplate? {
        guard let selectedSlotId = selectedSlotId else { return nil }
        return template.slots.first { $0.id == selectedSlotId }
    }
    
    // MARK: - Initialization
    
    init(board: VisionBoardEntity, template: VisionBoardTemplate) {
        self.board = board
        self.template = template
        
        setupImagePickerObserver()
    }
    
    // MARK: - Public Methods
    
    /// Select a slot for editing
    func selectSlot(_ slotId: Int) {
        selectedSlotId = slotId
        showingBottomSheet = true
        
        // Set up text editing if it's a text slot
        if let slot = selectedSlot, slot.slotType == "text" {
            editingText = slot.text ?? ""
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Dismiss the bottom sheet
    func dismissBottomSheet() {
        showingBottomSheet = false
        selectedSlotId = nil
        editingText = ""
        selectedImageItem = nil
    }
    
    /// Save text content for the selected slot
    func saveTextContent() {
        guard let selectedSlotId = selectedSlotId else { return }
        
        // Use the service to update the slot content
        if let boardId = board.id {
            visionBoardService.updateSlotContent(
                boardId: boardId,
                slotId: selectedSlotId,
                imageData: nil,
                text: editingText.isEmpty ? nil : editingText,
                fontName: nil,
                fontSize: nil,
                colorHex: nil
            )
        }
        
        // Refresh the board from Core Data
        refreshBoard()
        
        // Haptic feedback for save
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismissBottomSheet()
    }
    
    /// Remove content from the selected slot
    func removeSlotContent() {
        guard let selectedSlotId = selectedSlotId else { return }
        
        // Use the service to clear the slot content
        if let boardId = board.id {
            visionBoardService.updateSlotContent(
                boardId: boardId,
                slotId: selectedSlotId,
                imageData: nil,
                text: nil,
                fontName: nil,
                fontSize: nil,
                colorHex: nil
            )
        }
        
        // Refresh the board from Core Data
        refreshBoard()
        
        dismissBottomSheet()
    }
    
    // MARK: - Private Methods
    
    private func setupImagePickerObserver() {
        $selectedImageItem
            .compactMap { $0 }
            .sink { [weak self] item in
                self?.loadImage(from: item)
            }
            .store(in: &cancellables)
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        guard let selectedSlotId = selectedSlotId else { return }
        
        item.loadTransferable(type: Data.self) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let data):
                    if let data = data {
                        // Use the service to update the slot content
                        if let boardId = self?.board.id {
                            self?.visionBoardService.updateSlotContent(
                                boardId: boardId,
                                slotId: selectedSlotId,
                                imageData: data,
                                text: nil, // Clear text when adding image
                                fontName: nil,
                                fontSize: nil,
                                colorHex: nil
                            )
                        }
                        
                        // Refresh the board from Core Data
                        self?.refreshBoard()
                        
                        // Haptic feedback for image save
                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)
                        
                        self?.dismissBottomSheet()
                    }
                case .failure(let error):
                    print("❌ Error loading image: \(error)")
                }
            }
        }
    }
    
    private func refreshBoard() {
        // Refresh the board from Core Data to get the latest changes
        if let boardId = board.id, let updatedBoard = visionBoardService.fetchBoard(withId: boardId) {
            Task { @MainActor in
                self.board = updatedBoard
            }
        }
    }
}
