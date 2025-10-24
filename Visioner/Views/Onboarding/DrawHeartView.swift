//
//  DrawHeartView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct DrawHeartView: View {
    @State private var path = Path()
    @State private var isDrawing = false
    @State private var hasValidDrawing = false
    @State private var showHeader = false
    @State private var showInstruction = false
    @State private var showCanvas = false
    @State private var showContinueButton = false
    @State private var showSparkles = false
    @State private var canvasGlow = false
    @State private var breathingEffect = false
    @State private var showLovelyText = false
    @State private var heartFilled = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#7C64B2"), // lavender
                    Color(hex: "#E9A8D0")  // rose
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .scaleEffect(breathingEffect ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: breathingEffect)
            
            // Sparkle particles overlay
            if showSparkles {
                SparkleParticlesView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Header text
                if showHeader {
                    Text("First step is to love yourself")
                        .font(.appOnboardingQuote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showHeader ? 1 : 0)
                        .scaleEffect(showHeader ? 1.0 : 0.9)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .overlay(
                            // Glow effect
                            Text("First step is to love yourself")
                                .font(.appOnboardingQuote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .blur(radius: 8)
                                .opacity(showHeader ? 0.3 : 0)
                        )
                }
                
                Spacer()
                
                // Drawing canvas
                if showCanvas {
                    ZStack {
                        // Canvas glow effect
                        if canvasGlow || isDrawing {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color(hex: "#E9A8D0").opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 280, height: 280)
                                .blur(radius: 4)
                                .opacity(canvasGlow ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: canvasGlow)
                        }
                        
                        // Drawing canvas
                        DrawingCanvasView(
                            path: $path,
                            isDrawing: $isDrawing,
                            hasValidDrawing: $hasValidDrawing,
                            heartFilled: $heartFilled,
                            onDrawingComplete: {
                                // Handle drawing completion
                            },
                            onHeartDetected: {
                                handleHeartDetected()
                            }
                        )
                        .scaleEffect(showCanvas ? 1.0 : 0.95)
                        .opacity(showCanvas ? 1 : 0)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                
                // Instruction text
                if showInstruction && !showLovelyText {
                    Text("Use your finger to draw a heart")
                        .font(.appSecondary)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(showInstruction ? 1 : 0)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                // Lovely feedback text
                if showLovelyText {
                    Text("Lovely")
                        .font(.appOnboardingQuote)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showLovelyText ? 1 : 0)
                        .scaleEffect(showLovelyText ? 1.0 : 0.8)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .overlay(
                            // Glow effect
                            Text("Lovely")
                                .font(.appOnboardingQuote)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#E9A8D0"))
                                .blur(radius: 6)
                                .opacity(showLovelyText ? 0.4 : 0)
                        )
                }
                
                Spacer()

                // Continue button
                if showContinueButton {
                    Button(action: {
                        // Save the drawing
                        _ = DrawingImageService.saveDrawingToDisk(path: path)
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        onComplete()
                    }) {
                        HStack(spacing: 12) {
                            Text("✨ Continue")
                                .font(.appButton)
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
                    }
                    .scaleEffect(showContinueButton ? 1.0 : 0.8)
                    .opacity(showContinueButton ? 1 : 0)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startEntranceSequence()
        }
        .onChange(of: isDrawing) { drawing in
            if drawing {
                withAnimation(.easeInOut(duration: 0.3)) {
                    canvasGlow = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    canvasGlow = false
                }
            }
        }
    }
    
    private func startEntranceSequence() {
        // Start breathing animation
        breathingEffect = true
        
        // Header fade in
        withAnimation(.easeInOut(duration: 1.5)) {
            showHeader = true
        }
        
        // Canvas appear after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showCanvas = true
            }
        }
        
        // Instruction appears after canvas
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showInstruction = true
            }
        }
    }
    
    private func handleHeartDetected() {
        // Hide instruction text and show "Lovely" feedback
        withAnimation(.easeInOut(duration: 0.3)) {
            showInstruction = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showLovelyText = true
                heartFilled = true
            }
        }

        // Trigger sparkle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showSparkles = true
            }
        }

        // Show continue button after sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showContinueButton = true
            }
        }
        
        // Hide sparkles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showSparkles = false
            }
        }
    }
}

// MARK: - Sparkle Particles View

struct SparkleParticlesView: View {
    @State private var particles: [SparkleParticle] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                        .animation(.easeOut(duration: particle.lifetime), value: particle.position)
                        .animation(.easeOut(duration: particle.lifetime), value: particle.opacity)
                        .animation(.easeOut(duration: particle.lifetime), value: particle.scale)
                }
            }
        }
        .onAppear {
            startSparkleAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    private func startSparkleAnimation() {
        // Create initial burst of particles
        createSparkleBurst()
        
        // Create additional particles over time
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if particles.count < 50 { // Limit total particles
                createSparkleParticle()
            }
        }
        
        // Stop creating new particles after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            animationTimer?.invalidate()
        }
    }
    
    private func createSparkleBurst() {
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2
        
        // Create 20 particles radiating outward
        for i in 0..<20 {
            let angle = Double(i) * (2 * Double.pi / 20)
            let distance = Double.random(in: 80...120)
            
            let particle = SparkleParticle(
                position: CGPoint(
                    x: centerX + cos(angle) * distance,
                    y: centerY + sin(angle) * distance
                ),
                size: Double.random(in: 2...6),
                color: [Color(hex: "#E9A8D0"), Color(hex: "#C4B1E6"), Color(hex: "#F4EFFC")].randomElement() ?? Color.white,
                opacity: Double.random(in: 0.4...0.8),
                scale: 1.0,
                lifetime: Double.random(in: 2.0...3.0)
            )
            
            particles.append(particle)
            
            // Animate particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].position.y -= Double.random(in: 50...100)
                    particles[index].opacity = 0
                    particles[index].scale = 0.1
                }
            }
        }
    }
    
    private func createSparkleParticle() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        let particle = SparkleParticle(
            position: CGPoint(
                x: centerX + Double.random(in: -40...40),
                y: centerY + Double.random(in: -40...40)
            ),
            size: Double.random(in: 2...4),
            color: [Color(hex: "#E9A8D0"), Color(hex: "#C4B1E6"), Color(hex: "#F4EFFC")].randomElement() ?? Color.white,
            opacity: Double.random(in: 0.3...0.7),
            scale: 1.0,
            lifetime: Double.random(in: 1.5...2.5)
        )
        
        particles.append(particle)
        
        // Animate particle upward and fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].position.y -= Double.random(in: 60...120)
                particles[index].opacity = 0
                particles[index].scale = 0.1
            }
        }
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.lifetime) {
            particles.removeAll { $0.id == particle.id }
        }
    }
}

// MARK: - Sparkle Particle Model

struct SparkleParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: Double
    let color: Color
    var opacity: Double
    var scale: Double
    let lifetime: Double
}

#Preview {
    DrawHeartView {
        print("Draw heart completed")
    }
}
