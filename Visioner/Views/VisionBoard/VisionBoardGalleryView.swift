//
//  VisionBoardGalleryView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct VisionBoardGalleryView: View {
    @StateObject private var templateManager = TemplateManager()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(templateManager.templates) { template in
                        NavigationLink(destination: VisionBoardTemplateDetailView(template: template)) {
                            TemplateCardView(template: template)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .background(theme.background)
            .navigationTitle("Vision Boards")
            .font(.appLogo)
            .foregroundColor(theme.textPrimary)
        }
    }
}

struct TemplateCardView: View {
    let template: VisionBoardTemplate
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Template preview with enhanced elevation
            HStack {
                Spacer()
                UnifiedTemplateVisualizationView(template: template)
                    .aspectRatio(template.cgGridSize.width / template.cgGridSize.height, contentMode: .fit)
                    .frame(maxHeight: 300)
                    .background(
                        // Multi-layer background for depth with better contrast
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.background)
                            .shadow(color: theme.shadow.opacity(0.4), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        // More visible border for template preview
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.shadow.opacity(0.2), lineWidth: 1.5)
                    )
                    .clipped()
                Spacer()
            }
            
            // Content section with better spacing
            VStack(alignment: .leading, spacing: 8) {
                // Template name with enhanced typography
                Text(template.name)
                    .font(.appSecondary)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                // Slot count with badge-like styling
                HStack(spacing: 6) {
                    Image(systemName: "grid")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.accent)
                    
                    Text("\(template.slots.count) slots")
                        .font(.appCaption)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .padding(20)
        .background(
            // Enhanced card background with stronger contrast
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            theme.background,
                            theme.secondary.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // More visible border for better definition
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.shadow.opacity(0.25), lineWidth: 1.5)
                )
        )
        .frame(maxWidth: .infinity)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .shadow(
            color: theme.shadow.opacity(0.15),
            radius: isPressed ? 12 : 20,
            x: 0,
            y: isPressed ? 6 : 10
        )
        .shadow(
            color: theme.shadow.opacity(0.08),
            radius: isPressed ? 6 : 8,
            x: 0,
            y: isPressed ? 3 : 4
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            // Haptic feedback for better UX
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}



#Preview {
    VisionBoardGalleryView()
}
