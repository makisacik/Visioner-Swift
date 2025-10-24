//
//  VisionBoardService.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import CoreData
import SwiftUI
import Combine

/// Service class for managing vision board persistence using Core Data
final class VisionBoardService: ObservableObject {
    static let shared = VisionBoardService()
    
    private let viewContext: NSManagedObjectContext
    
    private init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    // MARK: - Public Methods
    
    /// Create a new vision board from a template
    func createBoard(from template: VisionBoardTemplate, title: String) -> VisionBoardEntity {
        let boardEntity = VisionBoardEntity(context: viewContext)
        boardEntity.id = UUID()
        boardEntity.templateId = template.id
        boardEntity.title = title
        boardEntity.createdDate = Date()
        
        for slotTemplate in template.slots {
            let slotContentEntity = SlotContentEntity(context: viewContext)
            slotContentEntity.id = Int16(slotTemplate.id)
            slotContentEntity.slotType = slotTemplate.type.rawValue
            slotContentEntity.board = boardEntity
            // Default text for text slots
            if slotTemplate.type == .text {
                slotContentEntity.text = "+ Write affirmation"
                slotContentEntity.fontName = template.theme?.fontName ?? AppFontName.nunitoSans
                slotContentEntity.fontSize = 16.0
                slotContentEntity.colorHex = template.theme?.accentColorHex ?? ThemeManager.shared.currentTheme.textPrimary.toHex()
            }
            boardEntity.addToSlots(slotContentEntity)
        }
        
        saveContext()
        return boardEntity
    }
    
    /// Update slot content
    func updateSlotContent(boardId: UUID, slotId: Int, imageData: Data?, text: String?, fontName: String?, fontSize: CGFloat?, colorHex: String?) {
        let fetchRequest: NSFetchRequest<SlotContentEntity> = SlotContentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "board.id == %@ AND id == %d", boardId as CVarArg, slotId)
        
        do {
            if let slotEntity = try viewContext.fetch(fetchRequest).first {
                slotEntity.imageData = imageData
                slotEntity.text = text
                slotEntity.fontName = fontName
                slotEntity.fontSize = fontSize.map { Double($0) } ?? 16.0
                slotEntity.colorHex = colorHex
                saveContext()
            }
        } catch {
            print("Failed to update slot content: \(error)")
        }
    }
    
    /// Fetch a board by ID
    func fetchBoard(withId id: UUID) -> VisionBoardEntity? {
        let fetchRequest: NSFetchRequest<VisionBoardEntity> = VisionBoardEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try viewContext.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch board: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Extensions

extension VisionBoardEntity {
    var slotsArray: [SlotContentEntity] {
        let set = slots as? Set<SlotContentEntity> ?? []
        return set.sorted { $0.id < $1.id }
    }
}
