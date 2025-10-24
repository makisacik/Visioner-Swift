//
//  ChooseYourVisionsView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct ChooseYourVisionsView: View {
    @StateObject private var viewModel: ChooseYourVisionsViewModel
    @State private var showHeader = false
    @State private var showSubtitle = false
    @State private var showPages = false
    @State private var showContinueButton = false
    @State private var showParticles = false
    @State private var breathingEffect = false
    
    let onContinue: () -> Void
    
    init(selectedDreams: Set<ChooseYourVisionsViewModel.DreamCategory>, onContinue: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: ChooseYourVisionsViewModel(selectedDreams: selectedDreams))
        self.onContinue = onContinue
    }
    
    var body: some View {
        ZStack {
            // Dynamic background with breathing effect
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
            .scaleEffect(breathingEffect ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: breathingEffect)
            
            // Floating particles overlay
            if showParticles {
                VisionParticlesView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    Text("Visualize Your Dreams")
                        .font(.appOnboardingQuote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showHeader ? 1 : 0)
                        .scaleEffect(showHeader ? 1.0 : 0.9)
                        .overlay(
                            // Glow effect
                            Text("Visualize Your Dreams")
                                .font(.appOnboardingQuote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .blur(radius: 8)
                                .opacity(showHeader ? 0.3 : 0)
                        )
                    
                    Text("Choose the images that inspire you")
                        .font(.appSecondary)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(showSubtitle ? 1 : 0)
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)
                .padding(.bottom, 30)
                                
                // Category Pages
                if showPages {
                    TabView(selection: $viewModel.currentCategoryIndex) {
                        ForEach(Array(viewModel.availableDreams.enumerated()), id: \.element) { index, dream in
                            VisionCategoryPageView(
                                dream: dream,
                                viewModel: viewModel
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 540)
                }
                
                Spacer()
                
                // Custom Page Indicators
                if showPages {
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.totalCategories, id: \.self) { index in
                            Circle()
                                .fill(index == viewModel.currentCategoryIndex ? 
                                      Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == viewModel.currentCategoryIndex ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.currentCategoryIndex)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Continue Button
                VStack(spacing: 12) {
                    if viewModel.canContinue {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                onContinue()
                            }
                        }) {
                            Text("Continue")
                                .font(.appButton)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#E9A8D0"),
                                            Color(hex: "#C4B1E6")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .scaleEffect(showContinueButton ? 1.0 : 0.8)
                        .opacity(showContinueButton ? 1.0 : 0.0)
                        .padding(.horizontal, 32)
                        
                        Text("You can always update your visions later")
                            .font(.appCaption)
                            .foregroundColor(.white.opacity(0.6))
                            .opacity(showContinueButton ? 1.0 : 0.0)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startEntranceAnimation()
        }
        .onChange(of: viewModel.canContinue) { canContinue in
            if canContinue && !showContinueButton {
                withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                    showContinueButton = true
                }
            }
        }
    }
    
    private func startEntranceAnimation() {
        // Start breathing effect
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            breathingEffect = true
        }
        
        // Show particles
        withAnimation(.easeInOut(duration: 0.5)) {
            showParticles = true
        }
        
        // Header fade in
        withAnimation(.easeInOut(duration: 1.0)) {
            showHeader = true
        }
        
        // Subtitle slide in
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            showSubtitle = true
        }
        
        // Pages rise up
        withAnimation(.easeInOut(duration: 0.6).delay(0.6)) {
            showPages = true
        }
    }
}

// MARK: - Vision Particles View

struct VisionParticlesView: View {
    @State private var particles: [VisionParticle] = []
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
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            createParticle()
        }
    }
    
    private func createParticle() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let particle = VisionParticle(
            position: CGPoint(
                x: Double.random(in: 0...screenWidth),
                y: screenHeight + 20
            ),
            size: Double.random(in: 2...6),
            color: [Color(hex: "#E9A8D0"), Color(hex: "#C4B1E6"), Color(hex: "#F4EFFC")].randomElement() ?? Color.white,
            opacity: Double.random(in: 0.2...0.5),
            lifetime: Double.random(in: 4.0...8.0)
        )
        
        particles.append(particle)
        
        // Animate particle upward with slight drift
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].position.y = -20
                particles[index].position.x += Double.random(in: -30...30)
                particles[index].opacity = 0
            }
        }
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.lifetime) {
            particles.removeAll { $0.id == particle.id }
        }
    }
}

// MARK: - Vision Particle Model

struct VisionParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: Double
    let color: Color
    var opacity: Double
    let lifetime: Double
}

#Preview {
    ChooseYourVisionsView(
        selectedDreams: [.love, .career, .wealth]
    ) {
        print("Visions selected, continuing...")
    }
}
