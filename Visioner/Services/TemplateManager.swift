//
//  TemplateManager.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import Combine

/// Manages vision board templates loaded from JSON bundle
final class TemplateManager: ObservableObject {
    @Published var templates: [VisionBoardTemplate] = []
    
    init() {
        loadTemplates()
    }
    
    private func loadTemplates() {
        guard let url = Bundle.main.url(forResource: "Templates", withExtension: "json") else {
            print("❌ Templates.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([VisionBoardTemplate].self, from: data)
            self.templates = decoded
            print("✅ Loaded \(decoded.count) vision board templates")
        } catch {
            print("❌ Error decoding templates:", error)
        }
    }
    
    /// Get template by ID
    func template(withId id: String) -> VisionBoardTemplate? {
        return templates.first { $0.id == id }
    }
}
