//
//  ChooseYourVisionsViewModel.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import Combine

final class ChooseYourVisionsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedImages: [DreamCategory: Set<String>] = [:]
    @Published var currentCategoryIndex: Int = 0
    @Published var canContinue: Bool = false
    
    // MARK: - Private Properties
    
    private let selectedDreams: [DreamCategory]
    private let imageIds = ["placeholder-1", "placeholder-2", "placeholder-3", "placeholder-4", 
                           "placeholder-5", "placeholder-6", "placeholder-7", "placeholder-8"]
    
    // MARK: - Initialization
    
    init(selectedDreams: Set<DreamCategory>) {
        self.selectedDreams = Array(selectedDreams)
        
        // Initialize empty selections for each dream category
        for dream in self.selectedDreams {
            selectedImages[dream] = Set<String>()
        }
        
        updateCanContinue()
    }
    
    // MARK: - Public Methods
    
    var availableDreams: [DreamCategory] {
        return selectedDreams
    }
    
    var currentDream: DreamCategory? {
        guard currentCategoryIndex < selectedDreams.count else { return nil }
        return selectedDreams[currentCategoryIndex]
    }
    
    var totalCategories: Int {
        return selectedDreams.count
    }
    
    func selectImage(_ imageId: String, for category: DreamCategory) {
        guard var currentSelection = selectedImages[category] else { return }
        
        if currentSelection.contains(imageId) {
            // Deselect image
            currentSelection.remove(imageId)
        } else if currentSelection.count < 3 {
            // Select image (max 3 per category)
            currentSelection.insert(imageId)
        }
        
        selectedImages[category] = currentSelection
        
        // Force UI update by updating the published property
        objectWillChange.send()
        updateCanContinue()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func isImageSelected(_ imageId: String, for category: DreamCategory) -> Bool {
        return selectedImages[category]?.contains(imageId) ?? false
    }
    
    func getSelectedCount(for category: DreamCategory) -> Int {
        return selectedImages[category]?.count ?? 0
    }
    
    func canSelectMore(for category: DreamCategory) -> Bool {
        return getSelectedCount(for: category) < 3
    }
    
    func moveToNextCategory() {
        guard currentCategoryIndex < selectedDreams.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentCategoryIndex += 1
        }
    }
    
    func moveToPreviousCategory() {
        guard currentCategoryIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentCategoryIndex -= 1
        }
    }
    
    func getSelectedImagesForCategory(_ category: DreamCategory) -> [String] {
        return Array(selectedImages[category] ?? Set<String>())
    }
    
    // MARK: - Private Methods
    
    private func updateCanContinue() {
        let allCategoriesHaveSelection = selectedDreams.allSatisfy { dream in
            let count = selectedImages[dream]?.count ?? 0
            return count >= 1
        }
        
        canContinue = allCategoriesHaveSelection
    }
}

// MARK: - Dream Category Extension

extension ChooseYourVisionsViewModel {
    enum DreamCategory: String, CaseIterable, Hashable {
        case love = "💖"
        case career = "💼"
        case wealth = "💰"
        case travel = "✈️"
        case health = "🌿"
        case creativity = "🎨"
        case success = "🌞"
        case peace = "🧘‍♀️"
        case home = "🏡"
        
        var title: String {
            switch self {
            case .love: return "Love"
            case .career: return "Career"
            case .wealth: return "Wealth"
            case .travel: return "Travel"
            case .health: return "Health"
            case .creativity: return "Creativity"
            case .success: return "Success"
            case .peace: return "Peace"
            case .home: return "Home"
            }
        }
        
        var categoryColor: Color {
            switch self {
            case .love: return Color(hex: "#E9A8D0") // rose pink
            case .career: return Color(hex: "#7C64B2") // lavender
            case .wealth: return Color(hex: "#F4D58D") // warm gold
            case .travel: return Color(hex: "#89CFF0") // sky blue
            case .health: return Color(hex: "#98D8C8") // mint green
            case .creativity: return Color(hex: "#C4B1E6") // soft purple
            case .success: return Color(hex: "#FFD89B") // sunrise gold
            case .peace: return Color(hex: "#B4C8D8") // serene blue
            case .home: return Color(hex: "#D4A5A5") // warm rose
            }
        }
    }
}
