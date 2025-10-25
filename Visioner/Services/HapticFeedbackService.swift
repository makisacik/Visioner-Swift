//
//  HapticFeedbackService.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import UIKit
import SwiftUI

/// Centralized haptic feedback service for consistent user experience
final class HapticFeedbackService {
    static let shared = HapticFeedbackService()
    
    private init() {}
    
    // MARK: - Feedback Types
    
    enum FeedbackType {
        case selection      // Light tap for selections
        case impact        // Medium impact for interactions
        case success       // Success notification
        case error         // Error notification
        case warning       // Warning notification
        case bloom         // Special bloom effect for content creation
        case focus         // Focus mode activation
        case export        // Export completion
    }
    
    // MARK: - Public Methods
    
    /// Provide haptic feedback based on type
    func provideFeedback(_ type: FeedbackType) {
        switch type {
        case .selection:
            provideSelectionFeedback()
        case .impact:
            provideImpactFeedback()
        case .success:
            provideSuccessFeedback()
        case .error:
            provideErrorFeedback()
        case .warning:
            provideWarningFeedback()
        case .bloom:
            provideBloomFeedback()
        case .focus:
            provideFocusFeedback()
        case .export:
            provideExportFeedback()
        }
    }
    
    // MARK: - Private Methods
    
    private func provideSelectionFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func provideImpactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func provideSuccessFeedback() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func provideErrorFeedback() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    private func provideWarningFeedback() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    private func provideBloomFeedback() {
        // Special sequence for bloom effect
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    private func provideFocusFeedback() {
        // Medium impact for focus mode
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func provideExportFeedback() {
        // Success notification for export
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
}

// MARK: - View Extension

extension View {
    /// Add haptic feedback to any view interaction
    func hapticFeedback(_ type: HapticFeedbackService.FeedbackType) -> some View {
        self.onTapGesture {
            HapticFeedbackService.shared.provideFeedback(type)
        }
    }
    
    /// Add haptic feedback to button press
    func buttonHapticFeedback(_ type: HapticFeedbackService.FeedbackType = .selection) -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded {
                    HapticFeedbackService.shared.provideFeedback(type)
                }
        )
    }
}
