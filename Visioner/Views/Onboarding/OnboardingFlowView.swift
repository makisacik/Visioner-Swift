//
//  OnboardingFlowView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentStep: OnboardingStep = .initial
    @State private var transitionProgress: Double = 0.0
    @State private var showTransitionParticles = false
    @State private var morphingGradient = false
    @State private var selectedDreams: Set<ChooseYourVisionsViewModel.DreamCategory> = []
    let onComplete: () -> Void
    
    enum OnboardingStep {
        case initial
        case drawHeart
        case transitioning
        case ethereal
        case chooseDreams
        case chooseVisions
        case complete
    }
    
    var body: some View {
        ZStack {
            // Dynamic background that morphs between the two themes
            MorphingBackgroundView(
                progress: transitionProgress,
                isMorphing: morphingGradient
            )
            .ignoresSafeArea()
            
            // Transition particles overlay
            if showTransitionParticles {
                TransitionParticlesView()
                    .opacity(showTransitionParticles ? 1 : 0)
            }
            
            switch currentStep {
            case .initial:
                OnboardingView {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentStep = .drawHeart
                    }
                }
                .transition(.opacity)
                
            case .drawHeart:
                DrawHeartView {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentStep = .chooseDreams
                    }
                }
                .transition(.opacity)
                
            case .transitioning:
                // Transition view with morphing effects
                TransitionView()
                    .opacity(transitionProgress)
                
            case .ethereal:
                EtherealOnboardingView {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentStep = .complete
                    }
                }
                .transition(.opacity)
                
            case .chooseDreams:
                ChooseYourDreamsView { dreams in
                    selectedDreams = dreams
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentStep = .chooseVisions
                    }
                }
                .transition(.opacity)

            case .chooseVisions:
                ChooseYourVisionsView(selectedDreams: selectedDreams) {
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
    
    private func startTransition() {
        // Start the morphing gradient
        withAnimation(.easeInOut(duration: 2.0)) {
            morphingGradient = true
        }
        
        // Show transition particles
        withAnimation(.easeInOut(duration: 0.5)) {
            showTransitionParticles = true
        }
        
        // Animate transition progress
        withAnimation(.easeInOut(duration: 2.5)) {
            transitionProgress = 1.0
        }
        
        // Move to transitioning state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                currentStep = .transitioning
            }
        }
        
        // Complete transition to ethereal
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                currentStep = .ethereal
                showTransitionParticles = false
            }
        }
    }
}

// MARK: - Morphing Background View

struct MorphingBackgroundView: View {
    let progress: Double
    let isMorphing: Bool
    
    var body: some View {
        ZStack {
            // Initial gradient (from first onboarding)
            LinearGradient(
                colors: [
                    Color(hex: "#7C64B2"),
                    Color(hex: "#4A3A6B")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(1.0 - progress)
            
            // Target gradient (for ethereal onboarding)
            LinearGradient(
                colors: [
                    Color(hex: "#4A3A6B"), // deep plum
                    Color(hex: "#7C64B2"), // lavender
                    Color(hex: "#F4EFFC")  // soft light
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .opacity(progress)
            
            // Morphing stars overlay
            if isMorphing {
                MorphingStarsView(progress: progress)
            }
        }
    }
}

// MARK: - Morphing Stars View

struct MorphingStarsView: View {
    let progress: Double
    @State private var starPositions: [CGPoint] = []
    @State private var starSizes: [CGFloat] = []
    @State private var starOpacities: [Double] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<starPositions.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(
                            width: starSizes[index] * (1.0 + progress * 2.0),
                            height: starSizes[index] * (1.0 + progress * 2.0)
                        )
                        .position(starPositions[index])
                        .opacity(starOpacities[index] * (0.3 + progress * 0.7))
                        .animation(
                            .easeInOut(duration: 2.0)
                            .delay(Double(index) * 0.02),
                            value: progress
                        )
                }
            }
        }
        .onAppear {
            generateStars()
        }
    }
    
    private func generateStars() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        starPositions = (0..<40).map { _ in
            CGPoint(
                x: Double.random(in: 0...screenWidth),
                y: Double.random(in: 0...screenHeight)
            )
        }
        
        starSizes = (0..<40).map { _ in
            CGFloat(Double.random(in: 1.0...3.0))
        }
        
        starOpacities = (0..<40).map { _ in
            Double.random(in: 0.2...0.8)
        }
    }
}

// MARK: - Transition View

struct TransitionView: View {
    @State private var sparkleRotation: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Sparkle animation
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Color(hex: "#F4EFFC"))
                        .offset(
                            x: cos(Double(index) * .pi / 4 + sparkleRotation) * 60,
                            y: sin(Double(index) * .pi / 4 + sparkleRotation) * 60
                        )
                        .opacity(0.6)
                        .animation(
                            .linear(duration: 8.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.1),
                            value: sparkleRotation
                        )
                }
            }
            .frame(width: 200, height: 200)
            
            // Transition text
            VStack(spacing: 16) {
                Text("Preparing your sacred space...")
                    .font(.custom("Playfair Display", size: 24))
                    .fontWeight(.light)
                    .foregroundColor(Color(hex: "#F4EFFC"))
                    .opacity(textOpacity)
                
                Text("✨")
                    .font(.system(size: 32))
                    .opacity(textOpacity)
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                textOpacity = 1.0
            }
            
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                sparkleRotation = .pi * 2
            }
        }
    }
}

// MARK: - Transition Particles View

struct TransitionParticlesView: View {
    @State private var particles: [TransitionParticle] = []
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
                        .animation(.easeOut(duration: particle.lifetime), value: particle.position)
                }
            }
        }
        .onAppear {
            startParticleAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    private func startParticleAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            createParticle()
        }
    }
    
    private func createParticle() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let particle = TransitionParticle(
            position: CGPoint(
                x: Double.random(in: 0...screenWidth),
                y: screenHeight + 20
            ),
            size: Double.random(in: 2...6),
            color: [Color(hex: "#E9A8D0"), Color(hex: "#C4B1E6"), Color(hex: "#F4EFFC")].randomElement() ?? Color.white,
            opacity: Double.random(in: 0.3...0.8),
            lifetime: Double.random(in: 2.0...4.0)
        )
        
        particles.append(particle)
        
        // Animate particle upward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].position.y = -20
                particles[index].opacity = 0
            }
        }
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.lifetime) {
            particles.removeAll { $0.id == particle.id }
        }
    }
}

// MARK: - Transition Particle Model

struct TransitionParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: Double
    let color: Color
    var opacity: Double
    let lifetime: Double
}

#Preview {
    OnboardingFlowView {
        print("Onboarding flow completed")
    }
}
