//
//  FocusModeOverlay.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

/// Focus mode overlay that dims background and zooms selected slot
struct FocusModeOverlay: View {
    let slot: VisionSlotTemplate
    let slotContent: SlotContentEntity?
    let rect: CGRect
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .opacity(isVisible ? 1.0 : 0.0)
                .onTapGesture {
                    dismissFocusMode()
                }
            
            // Focused slot content
            if isVisible {
                focusedSlotView
                    .scaleEffect(isVisible ? 1.0 : 0.8)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
            }
            
            // Glow effect behind focused slot
            if isVisible {
                glowEffect
                    .opacity(glowIntensity)
            }
            
            // Dismiss button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: dismissFocusMode) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(theme.background)
                            .background(
                                Circle()
                                    .fill(theme.shadow.opacity(0.8))
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: isVisible)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
            
            // Set glow intensity
            glowIntensity = 1.0
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismissFocusMode()
                    }
                }
        )
    }
    
    // MARK: - Focused Slot View
    
    private var focusedSlotView: some View {
        VStack(spacing: 20) {
            // Slot content
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.background)
                    .frame(width: min(rect.width * 2, 300), height: min(rect.height * 2, 300))
                    .shadow(color: theme.shadow, radius: 20, x: 0, y: 10)
                
                if let content = slotContent, hasContent {
                    contentView(for: content)
                } else {
                    placeholderView
                }
            }
            
            // Slot type indicator
            HStack(spacing: 8) {
                Image(systemName: slot.type == .image ? "photo" : "text.quote")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.accent)
                
                Text(slot.type == .image ? "Image Slot" : "Affirmation Slot")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondary.opacity(0.3))
            )
        }
    }
    
    // MARK: - Glow Effect
    
    private var glowEffect: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.accent.opacity(0.3),
                            theme.accent.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 20)
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.accentStrong.opacity(0.4),
                            theme.accent.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 10)
        }
    }
    
    // MARK: - Content Views
    
    private var hasContent: Bool {
        guard let content = slotContent else { return false }
        return content.imageData != nil || (content.text != nil && !content.text!.isEmpty)
    }
    
    @ViewBuilder
    private func contentView(for content: SlotContentEntity) -> some View {
        if slot.type == .image, let imageData = content.imageData {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: min(rect.width * 2, 300), height: min(rect.height * 2, 300))
                    .clipped()
                    .cornerRadius(20)
            } else {
                placeholderView
            }
        } else if slot.type == .text, let text = content.text, !text.isEmpty {
            Text(text)
                .font(.appOnboardingQuote)
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(20)
                .frame(width: min(rect.width * 2, 300), height: min(rect.height * 2, 300))
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: slot.type == .image ? "photo" : "text.quote")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(theme.textSecondary.opacity(0.6))
            
            Text(placeholderText)
                .font(.appSecondary)
                .foregroundColor(theme.textSecondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(width: min(rect.width * 2, 300), height: min(rect.height * 2, 300))
    }
    
    private var placeholderText: String {
        slot.type == .image ? "Tap to add your vision" : "Tap to write your affirmation"
    }
    
    // MARK: - Actions
    
    private func dismissFocusMode() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isVisible = false
            glowIntensity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
        
        // Haptic feedback
        HapticFeedbackService.shared.provideFeedback(.selection)
    }
}

// MARK: - Preview

#Preview {
    let sampleSlot = VisionSlotTemplate(
        id: 1,
        rect: CodableRect(from: CGRect(x: 0, y: 0, width: 4, height: 4)),
        type: .text
    )
    
    FocusModeOverlay(
        slot: sampleSlot,
        slotContent: nil,
        rect: CGRect(x: 0, y: 0, width: 200, height: 200),
        onDismiss: {}
    )
}
