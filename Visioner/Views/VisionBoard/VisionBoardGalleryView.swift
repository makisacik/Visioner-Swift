//
//  VisionBoardGalleryView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct VisionBoardGalleryView: View {
    @StateObject private var templateManager = TemplateManager()
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(templateManager.templates) { template in
                        NavigationLink(destination: VisionBoardTemplateDetailView(template: template)) {
                            TemplateCardView(template: template)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Vision Boards")
            .font(.appLogo)
        }
    }
}

struct TemplateCardView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Template preview
            TemplatePreviewView(template: template)
                .frame(height: 120)
                .background(theme.secondary.opacity(0.3))
            
            // Template name
            Text(template.name)
                .font(.appSecondary)
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.leading)
            
            // Slot count info
            Text("\(template.slots.count) slots")
                .font(.appCaption)
                .foregroundColor(theme.textSecondary)
        }
        .padding(12)
        .background(theme.secondary.opacity(0.1))
    }
}

struct TemplatePreviewView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / template.cgGridSize.width
            let cellHeight = cellWidth // Make cells square for proper proportions
            
            ZStack {
                // Background
                Rectangle()
                    .fill(theme.background)
                
                // Slots
                ForEach(template.slots) { slot in
                    let rect = CGRect(
                        x: slot.cgRect.origin.x * cellWidth,
                        y: slot.cgRect.origin.y * cellHeight,
                        width: slot.cgRect.width * cellWidth,
                        height: slot.cgRect.height * cellHeight
                    )
                    
                    Rectangle()
                        .fill(slot.type == .image ? theme.accent.opacity(0.3) : theme.accentStrong.opacity(0.2))
                        .frame(width: rect.width, height: rect.height)
                        .position(
                            x: rect.midX,
                            y: rect.midY
                        )
                }
            }
        }
    }
}

#Preview {
    VisionBoardGalleryView()
}
