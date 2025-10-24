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
        }
    }
}

struct TemplateCardView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Template preview with prefilled content - centered within fixed width
            HStack {
                Spacer()
                TemplatePreviewView(template: template)
                    .aspectRatio(template.cgGridSize.width / template.cgGridSize.height, contentMode: .fit)
                    .frame(maxHeight: 300) // Maximum height to prevent cards from being too tall
                    .background(theme.secondary.opacity(0.3))
                    .cornerRadius(12)
                Spacer()
            }
            
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
        .padding(16)
        .background(theme.secondary.opacity(0.1))
        .cornerRadius(16)
        .frame(maxWidth: .infinity) // Make all cards the same width
        .shadow(color: theme.shadow, radius: 8, x: 0, y: 4) // Add shadow to cards
    }
}

struct TemplatePreviewView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / template.cgGridSize.width
            let cellHeight = cellWidth // Make cells square for proper proportions
            
            ZStack {
                // Background with theme color
                Rectangle()
                    .fill(Color(hex: template.theme?.backgroundColorHex ?? "#F4EFFC") ?? theme.background)
                
                // Render slots directly (they handle their own positioning and sizing)
                ForEach(template.slots) { slot in
                    let rect = CGRect(
                        x: slot.cgRect.origin.x * cellWidth,
                        y: slot.cgRect.origin.y * cellHeight,
                        width: slot.cgRect.width * cellWidth,
                        height: slot.cgRect.height * cellHeight
                    )
                    
                    SlotPreviewView(
                        slot: slot,
                        rect: rect,
                        template: template
                    )
                }
            }
        }
    }
}

struct SlotPreviewView: View {
    let slot: VisionSlotTemplate
    let rect: CGRect
    let template: VisionBoardTemplate
    
    private var placeholderImageName: String {
        let imageIndex = (slot.id % 8) + 1
        return "placeholder-\(imageIndex)"
    }
    
    var body: some View {
        ZStack {
            if slot.type == .image {
                // Image slot with template image asset - no corner radius
                Image(placeholderImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
            } else {
                // Text slot with sample affirmation
                Rectangle()
                    .fill(theme.accentStrong.opacity(0.1))
                    .overlay(
                        Text(sampleAffirmation(for: slot.id))
                            .font(.system(size: min(rect.width, rect.height) * 0.15, weight: .medium))
                            .foregroundColor(Color(hex: template.theme?.accentColorHex ?? "#E9A8D0") ?? theme.accentStrong)
                            .multilineTextAlignment(.center)
                            .padding(4)
                    )
            }
            
            // Add separator lines around the slot
            Rectangle()
                .stroke(theme.shadow.opacity(0.2), lineWidth: 1)
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }
    
    private func sampleAffirmation(for slotId: Int) -> String {
        let affirmations = [
            "I am worthy",
            "Success flows to me",
            "I am grateful",
            "Abundance is mine",
            "Love surrounds me",
            "I am confident",
            "Dreams come true",
            "I am blessed"
        ]
        return affirmations[slotId % affirmations.count]
    }
}

#Preview {
    VisionBoardGalleryView()
}
