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
            ZStack {
                // Main background
                theme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header section with secondary background
                    VStack(spacing: 16) {
                        // Header with title
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Vision Boards")
                                    .font(.appLogo)
                                    .foregroundColor(theme.textPrimary)

                                Text("Choose Your Dreams")
                                    .font(.appCaption)
                                    .foregroundColor(theme.textSecondary)
                            }

                            Spacer()
                            
                            // My Boards button
                            NavigationLink(destination: MyBoardsView()) {
                                HStack(spacing: 6) {
                                    Image(systemName: "folder")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("My Boards")
                                        .font(.appCaption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(theme.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.accent.opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(
                        GeometryReader { geometry in
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    theme.secondary.opacity(0.1),
                                    theme.secondary.opacity(0.05),
                                    theme.background
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .ignoresSafeArea(.all, edges: .top)
                    )

                    // Content
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
                }
            }
        }
    }
}

struct TemplateCardView: View {
    let template: VisionBoardTemplate
    
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
                            .shadow(color: theme.shadow, radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        // More visible border for template preview
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.shadow, lineWidth: 1.5)
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
                .fill(theme.secondary)
                .overlay(
                    // More visible border for better definition
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.shadow, lineWidth: 1.5)
                )
        )
        .frame(maxWidth: .infinity)
        .shadow(
            color: theme.shadow,
            radius: 20,
            x: 0,
            y: 10
        )
        .shadow(
            color: theme.shadow,
            radius: 8,
            x: 0,
            y: 4
        )
    }
}



#Preview {
    VisionBoardGalleryView()
}
