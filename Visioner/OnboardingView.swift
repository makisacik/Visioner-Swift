//
//  OnboardingView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var showFirstLine = false
    @State private var showSecondLine = false
    @State private var showThirdLine = false
    @State private var showFourthLine = false
    @State private var showFifthLine = false
    @State private var showContinueButton = false
    @State private var starTwinkle = false
    @State private var shimmerEffect = false
    @State private var energyBurst = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Dark lavender gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#7C64B2"),
                    Color(hex: "#4A3A6B")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Twinkling stars background
            StarsView(twinkle: starTwinkle)
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Line 1: "You have dreams..."
                    if showFirstLine {
                        Text("You have dreams...")
                            .font(.appOnboardingQuote)
                            .foregroundColor(.white)
                            .opacity(showFirstLine ? 1 : 0)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                    
                    // Line 2: "they rest at the bottom of your heart."
                    if showSecondLine {
                        Text("they rest at the bottom of your heart.")
                            .font(.appOnboardingQuote)
                            .foregroundColor(.white)
                            .opacity(showSecondLine ? 1 : 0)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            .overlay(
                                // Shimmer effect when this line appears
                                shimmerEffect ? 
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.3), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text("they rest at the bottom of your heart.")
                                        .font(.appOnboardingQuote)
                                )
                                .animation(.easeInOut(duration: 1.5).repeatCount(2, autoreverses: true), value: shimmerEffect)
                                : nil
                            )
                    }
                    
                    // Lines 3 & 4: "They're not far away..." and "they're waiting..."
                    if showThirdLine {
                        VStack(spacing: 12) {
                            Text("They're not far away...")
                                .font(.appOnboardingQuote)
                                .foregroundColor(.white)
                                .opacity(showThirdLine ? 1 : 0)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            
                            Text("they're waiting...")
                                .font(.appOnboardingQuote)
                                .foregroundColor(.white)
                                .opacity(showThirdLine ? 1 : 0)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                    
                    // Line 5: "for you to bring them to life."
                    if showFifthLine {
                        Text("for you to bring them to life.")
                            .font(.appOnboardingQuote)
                            .foregroundColor(.white)
                            .opacity(showFifthLine ? 1 : 0)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .overlay(
                                // Energy burst effect
                                energyBurst ?
                                ZStack {
                                    ForEach(0..<8, id: \.self) { index in
                                        Circle()
                                            .fill(Color.white.opacity(0.6))
                                            .frame(width: 4, height: 4)
                                            .offset(
                                                x: cos(Double(index) * .pi / 4) * 60,
                                                y: sin(Double(index) * .pi / 4) * 60
                                            )
                                            .opacity(energyBurst ? 0 : 1)
                                            .animation(
                                                .easeOut(duration: 0.8)
                                                .delay(Double(index) * 0.1),
                                                value: energyBurst
                                            )
                                    }
                                }
                                : nil
                            )
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue button
                if showContinueButton {
                    Button(action: onComplete) {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.appButton)
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .opacity(showContinueButton ? 1 : 0)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
                
                Spacer()
            }
        }
        .onAppear {
            startOnboardingSequence()
        }
    }
    
    private func startOnboardingSequence() {
        // Line 1 appears immediately
        withAnimation(.easeInOut(duration: 1.5)) {
            showFirstLine = true
        }
        
        // Line 2 appears after 1.5s delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showSecondLine = true
            }
            
            // Trigger shimmer effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shimmerEffect = true
            }
        }
        
        // Stars twinkle faster after line 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            starTwinkle = true
        }
        
        // Lines 3 & 4 appear together after pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showThirdLine = true
            }
        }
        
        // Line 5 appears with upward motion
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showFifthLine = true
            }
            
            // Trigger energy burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                energyBurst = true
            }
        }
        
        // Continue button appears after all text
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showContinueButton = true
            }
        }
    }
}

// MARK: - Stars Background View

struct StarsView: View {
    let twinkle: Bool
    @State private var starPositions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<starPositions.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 2, height: 2)
                        .position(starPositions[index])
                        .opacity(twinkle ? Double.random(in: 0.3...1.0) : 0.8)
                        .animation(
                            .easeInOut(duration: Double.random(in: 1.0...2.0))
                            .repeatForever(autoreverses: true),
                            value: twinkle
                        )
                }
            }
        }
        .onAppear {
            generateStarPositions()
        }
    }
    
    private func generateStarPositions() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        starPositions = (0..<50).map { _ in
            CGPoint(
                x: Double.random(in: 0...screenWidth),
                y: Double.random(in: 0...screenHeight)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}
