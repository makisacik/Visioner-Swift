//
//  EtherealOnboardingView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import CoreMotion
import Combine

struct EtherealOnboardingView: View {
    @State private var showBackgroundStars = false
    @State private var showFirstLine = false
    @State private var showSecondLine = false
    @State private var showThirdLine = false
    @State private var showContinueButton = false
    @State private var breathingEffect = false
    @State private var shimmerEffect = false
    @State private var mirrorRipple = false
    @State private var lightOrbs = false
    @State private var starsBrighten = false
    
    // Motion manager for parallax effect
    @StateObject private var motionManager = MotionManager()
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Base gradient: deep plum → lavender → soft light
            LinearGradient(
                colors: [
                    Color(hex: "#4A3A6B"), // deep plum
                    Color(hex: "#7C64B2"), // lavender
                    Color(hex: "#F4EFFC")  // soft light
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            // Multiple layers of stars with parallax
            StarsLayerView(
                opacity: 0.3,
                size: 1.5,
                driftSpeed: 8.0,
                motionOffset: motionManager.roll * 0.1
            )
            .opacity(showBackgroundStars ? 0.5 : 0)
            
            StarsLayerView(
                opacity: 0.2,
                size: 2.5,
                driftSpeed: 12.0,
                motionOffset: motionManager.roll * 0.15
            )
            .opacity(showBackgroundStars ? 0.4 : 0)
            
            StarsLayerView(
                opacity: 0.1,
                size: 4.0,
                driftSpeed: 15.0,
                motionOffset: motionManager.roll * 0.2
            )
            .opacity(showBackgroundStars ? 0.3 : 0)
            
            // Light orbs that shimmer near text center
            if lightOrbs {
                LightOrbsView()
                    .opacity(0.6)
            }
            
            // Mirror ripple effect behind text
            if mirrorRipple {
                MirrorRippleView()
                    .opacity(0.3)
            }
            
            VStack {
                Spacer()
                
                // Main text content - centered vertically at ~40% from top
                VStack(spacing: 16) {
                    // Line 1: "This is where your vision comes to life."
                    if showFirstLine {
                        Text("This is where your vision comes to life.")
                            .font(.custom("Playfair Display", size: 36))
                            .fontWeight(.regular)
                            .foregroundColor(Color(hex: "#F4EFFC").opacity(0.9))
                            .tracking(1.01) // +1% letter spacing
                            .lineSpacing(1.4)
                            .multilineTextAlignment(.center)
                            .opacity(showFirstLine ? 1 : 0)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            .overlay(
                                // Outer glow effect
                                Text("This is where your vision comes to life.")
                                    .font(.custom("Playfair Display", size: 36))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(hex: "#E9A8D0").opacity(0.2))
                                    .blur(radius: 8)
                                    .opacity(showFirstLine ? 1 : 0)
                            )
                    }
                    
                    // Line 2: "Each picture, each affirmation —"
                    if showSecondLine {
                        Text("Each picture, each affirmation —")
                            .font(.custom("Playfair Display", size: 28))
                            .fontWeight(.light)
                            .foregroundColor(Color(hex: "#F4EFFC").opacity(0.9))
                            .tracking(1.01)
                            .lineSpacing(1.4)
                            .multilineTextAlignment(.center)
                            .opacity(showSecondLine ? 1 : 0)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            .overlay(
                                // Shimmer effect on ellipses
                                shimmerEffect ?
                                LinearGradient(
                                    colors: [.clear, Color(hex: "#F4EFFC").opacity(0.4), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text("Each picture, each affirmation —")
                                        .font(.custom("Playfair Display", size: 28))
                                        .fontWeight(.light)
                                )
                                .animation(.easeInOut(duration: 1.5).repeatCount(2, autoreverses: true), value: shimmerEffect)
                                : nil
                            )
                    }
                    
                    // Line 3: "a reminder of the future you're building."
                    if showThirdLine {
                        Text("a reminder of the future you're building.")
                            .font(.custom("Playfair Display", size: 24))
                            .fontWeight(.medium)
                            .italic()
                            .foregroundColor(Color(hex: "#F4EFFC").opacity(0.9))
                            .tracking(1.01)
                            .lineSpacing(1.4)
                            .multilineTextAlignment(.center)
                            .opacity(showThirdLine ? 1 : 0)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .overlay(
                                // Outer glow effect
                                Text("a reminder of the future you're building.")
                                    .font(.custom("Playfair Display", size: 24))
                                    .fontWeight(.medium)
                                    .italic()
                                    .foregroundColor(Color(hex: "#E9A8D0").opacity(0.2))
                                    .blur(radius: 6)
                                    .opacity(showThirdLine ? 1 : 0)
                            )
                    }
                }
                .scaleEffect(breathingEffect ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: breathingEffect)
                
                Spacer()
                
                // Continue button
                if showContinueButton {
                    Button(action: {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onComplete()
                    }) {
                        HStack(spacing: 12) {
                            Text("✨ Continue")
                                .font(.custom("Inter 28pt Medium", size: 18))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#E9A8D0"),
                                            Color(hex: "#C4B1E6")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .scaleEffect(showContinueButton ? 1.0 : 0.8)
                        .opacity(showContinueButton ? 1 : 0)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                    .padding(.bottom, 60)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startEtherealSequence()
        }
    }
    
    private func startEtherealSequence() {
        // 0-2s: Fade in background stars
        withAnimation(.easeInOut(duration: 2.0)) {
            showBackgroundStars = true
        }
        
        // 2s: Fade in line 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showFirstLine = true
            }
        }
        
        // 4s: Fade in line 2 with shimmer
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showSecondLine = true
            }
            
            // Trigger shimmer effect on ellipses
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shimmerEffect = true
            }
        }
        
        // 6s: Fade in line 3 with upward float
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showThirdLine = true
            }
            
            // Trigger mirror ripple effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                mirrorRipple = true
            }
        }
        
        // 8s: Breathing effect on all text
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            breathingEffect = true
        }
        
        // 10s: Stars brighten, text fades, continue button appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                starsBrighten = true
            }
            
            // Text fades upward
            withAnimation(.easeInOut(duration: 1.5)) {
                showFirstLine = false
                showSecondLine = false
                showThirdLine = false
            }
            
            // Continue button appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showContinueButton = true
                }
            }
        }
    }
}

// MARK: - Stars Layer View

struct StarsLayerView: View {
    let opacity: Double
    let size: CGFloat
    let driftSpeed: Double
    let motionOffset: Double
    
    @State private var starPositions: [CGPoint] = []
    @State private var driftOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<starPositions.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(opacity))
                        .frame(width: size, height: size)
                        .position(
                            x: starPositions[index].x + motionOffset * 50,
                            y: starPositions[index].y + driftOffset
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 2.0...4.0))
                            .repeatForever(autoreverses: true),
                            value: driftOffset
                        )
                }
            }
        }
        .onAppear {
            generateStarPositions()
            startDriftAnimation()
        }
    }
    
    private func generateStarPositions() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        starPositions = (0..<30).map { _ in
            CGPoint(
                x: Double.random(in: 0...screenWidth),
                y: Double.random(in: 0...screenHeight)
            )
        }
    }
    
    private func startDriftAnimation() {
        withAnimation(.linear(duration: driftSpeed).repeatForever(autoreverses: false)) {
            driftOffset = -UIScreen.main.bounds.height
        }
    }
}

// MARK: - Light Orbs View

struct LightOrbsView: View {
    @State private var shimmer = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Large orb near center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#F4EFFC").opacity(0.3),
                                Color(hex: "#E9A8D0").opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4)
                    .scaleEffect(shimmer ? 1.1 : 1.0)
                    .opacity(shimmer ? 0.8 : 0.4)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: shimmer)
                
                // Smaller orbs
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(hex: "#F4EFFC").opacity(0.2))
                        .frame(width: 20, height: 20)
                        .position(
                            x: geometry.size.width * (0.3 + Double(index) * 0.2),
                            y: geometry.size.height * (0.35 + Double(index) * 0.1)
                        )
                        .scaleEffect(shimmer ? 1.2 : 0.8)
                        .opacity(shimmer ? 0.6 : 0.3)
                        .animation(
                            .easeInOut(duration: Double.random(in: 2.0...4.0))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: shimmer
                        )
                }
            }
        }
        .onAppear {
            shimmer = true
        }
    }
}

// MARK: - Mirror Ripple View

struct MirrorRippleView: View {
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 0.3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color(hex: "#E9A8D0").opacity(rippleOpacity), lineWidth: 2)
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4)
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity)
                        .animation(
                            .easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                            value: rippleScale
                        )
                }
            }
        }
        .onAppear {
            withAnimation {
                rippleScale = 2.0
                rippleOpacity = 0.0
            }
        }
    }
}

// MARK: - Motion Manager

class MotionManager: ObservableObject {
    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    
    private let motionManager = CMMotionManager()
    
    init() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let motion = motion else { return }
                self?.roll = motion.attitude.roll
                self?.pitch = motion.attitude.pitch
            }
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Preview

#Preview {
    EtherealOnboardingView {
        print("Ethereal onboarding completed")
    }
}
