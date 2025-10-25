//
//  VisionerApp.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import CoreData

@main
struct VisionerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var onboardingManager = OnboardingManager()

    init() {
        // Initialize font loader to register custom fonts
        _ = FontLoader.shared
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingManager.hasCompletedOnboarding {
                    VisionBoardGalleryView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    OnboardingFlowView {
                        onboardingManager.completeOnboarding()
                    }
                }
            }
            .environmentObject(onboardingManager)
        }
    }
}
