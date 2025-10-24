//
//  ChooseYourDreamsView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct ChooseYourDreamsView: View {
    @State private var selectedDreams: Set<DreamCategory> = []
    @State private var headerOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var cardsOpacity: Double = 0
    @State private var continueButtonOpacity: Double = 0
    @State private var showDreamParticles = false
    
    let onContinue: (Set<DreamCategory>) -> Void
    
    typealias DreamCategory = ChooseYourVisionsViewModel.DreamCategory
    
    var body: some View {
        ZStack {
            // Dream particles background
            if showDreamParticles {
                DreamParticlesView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Text("✨ Choose Your Dreams")
                        .font(.appOnboardingQuote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(headerOpacity)
                        .overlay(
                            // Glow effect
                            Text("✨ Choose Your Dreams")
                                .font(.appOnboardingQuote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .blur(radius: 8)
                                .opacity(headerOpacity * 0.3)
                        )
                    
                    // Subtitle
                    Text("Select 2-3 dreams you're ready to bring to life")
                        .font(.appSecondary)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(subtitleOpacity)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Dream Cards Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(DreamCategory.allCases, id: \.self) { dream in
                        DreamCardView(
                            dream: dream,
                            isSelected: selectedDreams.contains(dream)
                        ) {
                            selectDream(dream)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(cardsOpacity)
                
                Spacer()
                
                // Continue Button
                VStack(spacing: 12) {
                    if selectedDreams.count >= 2 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                onContinue(selectedDreams)
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
                        .scaleEffect(continueButtonOpacity)
                        .opacity(continueButtonOpacity)
                        .padding(.horizontal, 32)
                        
                        Text("You can always update your dreams later")
                            .font(.appCaption)
                            .foregroundColor(.white.opacity(0.6))
                            .opacity(continueButtonOpacity)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startEntranceAnimation()
        }
    }
    
    private func selectDream(_ dream: DreamCategory) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            if selectedDreams.contains(dream) {
                selectedDreams.remove(dream)
            } else if selectedDreams.count < 3 {
                selectedDreams.insert(dream)
            }
        }
        
        // Show continue button when threshold is met
        if selectedDreams.count >= 2 && continueButtonOpacity == 0 {
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                continueButtonOpacity = 1.0
            }
        } else if selectedDreams.count < 2 {
            withAnimation(.easeInOut(duration: 0.3)) {
                continueButtonOpacity = 0.0
            }
        }
    }
    
    private func startEntranceAnimation() {
        // Show dream particles
        withAnimation(.easeInOut(duration: 0.5)) {
            showDreamParticles = true
        }
        
        // Header fade in
        withAnimation(.easeInOut(duration: 1.0)) {
            headerOpacity = 1.0
        }
        
        // Subtitle slide in
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            subtitleOpacity = 1.0
        }
        
        // Cards rise up sequentially
        withAnimation(.easeInOut(duration: 0.6).delay(0.6)) {
            cardsOpacity = 1.0
        }
    }
}

// MARK: - Dream Card View

struct DreamCardView: View {
    let dream: ChooseYourDreamsView.DreamCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var cardScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Emoji
                Text(dream.rawValue)
                    .font(.system(size: 40))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                // Title
                Text(dream.title)
                    .font(.appBody)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [
                                Color(hex: "#E9A8D0").opacity(0.8),
                                Color(hex: "#C4B1E6").opacity(0.6)
                            ] : [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? Color(hex: "#E9A8D0").opacity(0.4) : Color.clear,
                        radius: isSelected ? 12 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
            )
            .scaleEffect(cardScale)
            .overlay(
                // Glow effect for selected cards
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#E9A8D0"),
                                Color(hex: "#C4B1E6")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .opacity(glowIntensity)
                    .blur(radius: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isSelected) { selected in
            if selected {
                withAnimation(.easeInOut(duration: 0.3)) {
                    glowIntensity = 1.0
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    glowIntensity = 0.0
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
            // Press animation
            withAnimation(.easeInOut(duration: 0.1)) {
                cardScale = 0.95
            }
        } onPressingChanged: { pressing in
            if !pressing {
                withAnimation(.easeInOut(duration: 0.1)) {
                    cardScale = 1.0
                }
            }
        }
    }
}

// MARK: - Dream Particles View

struct DreamParticlesView: View {
    @State private var particles: [DreamParticle] = []
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
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            createParticle()
        }
    }
    
    private func createParticle() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let particle = DreamParticle(
            position: CGPoint(
                x: Double.random(in: 0...screenWidth),
                y: screenHeight + 20
            ),
            size: Double.random(in: 3...8),
            color: [Color(hex: "#E9A8D0"), Color(hex: "#C4B1E6"), Color(hex: "#F4EFFC")].randomElement() ?? Color.white,
            opacity: Double.random(in: 0.2...0.6),
            lifetime: Double.random(in: 3.0...6.0)
        )
        
        particles.append(particle)
        
        // Animate particle upward with slight drift
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].position.y = -20
                particles[index].position.x += Double.random(in: -50...50)
                particles[index].opacity = 0
            }
        }
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.lifetime) {
            particles.removeAll { $0.id == particle.id }
        }
    }
}

// MARK: - Dream Particle Model

struct DreamParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: Double
    let color: Color
    var opacity: Double
    let lifetime: Double
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "#4A3A6B"),
                Color(hex: "#7C64B2"),
                Color(hex: "#F4EFFC")
            ],
            startPoint: .bottom,
            endPoint: .top
        )
        .ignoresSafeArea()
        
        ChooseYourDreamsView { dreams in
            print("Dreams selected: \(dreams), continuing...")
        }
    }
}
