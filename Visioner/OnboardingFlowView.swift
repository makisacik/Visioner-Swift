//
//  OnboardingFlowView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentStep: OnboardingStep = .initial
    let onComplete: () -> Void
    
    enum OnboardingStep {
        case initial
        case ethereal
        case complete
    }
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .initial:
                OnboardingView {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentStep = .ethereal
                    }
                }
                .transition(.opacity)
                
            case .ethereal:
                EtherealOnboardingView {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentStep = .complete
                    }
                }
                .transition(.opacity)
                
            case .complete:
                // Brief pause before completing
                Color.clear
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onComplete()
                        }
                    }
            }
        }
    }
}

#Preview {
    OnboardingFlowView {
        print("Onboarding flow completed")
    }
}
