//
//  OnboardingManager.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import Combine

/// Manages the onboarding state and determines whether to show onboarding or main app
final class OnboardingManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        loadOnboardingState()
    }
    
    /// Completes the onboarding and saves the state
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }
    
    /// Resets onboarding state (useful for testing)
    func resetOnboarding() {
        hasCompletedOnboarding = false
        userDefaults.removeObject(forKey: onboardingKey)
    }
    
    private func loadOnboardingState() {
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
    }
}
