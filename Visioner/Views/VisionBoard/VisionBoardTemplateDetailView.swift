//
//  VisionBoardTemplateDetailView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct VisionBoardTemplateDetailView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Template title
                Text(template.name)
                    .font(.appLogo)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                // Template visualization
                TemplateVisualizationView(template: template)
                    .padding(.horizontal, 10)
                
                // Template info
                TemplateInfoView(template: template)
                    .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .background(theme.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TemplateVisualizationView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width // Use full width
            let cellWidth = availableWidth / template.cgGridSize.width
            let cellHeight = cellWidth // Make cells square for proper proportions
            let totalHeight = cellHeight * template.cgGridSize.height
            
            ZStack {
                // Background
                Rectangle()
                    .fill(theme.background)
                    .cornerRadius(16)
                    .shadow(color: theme.shadow, radius: 8, x: 0, y: 4)
                
                // Grid slots
                ForEach(template.slots) { slot in
                    let rect = CGRect(
                        x: slot.cgRect.origin.x * cellWidth,
                        y: slot.cgRect.origin.y * cellHeight,
                        width: slot.cgRect.width * cellWidth,
                        height: slot.cgRect.height * cellHeight
                    )
                    
                    SlotView(
                        slot: slot,
                        rect: rect,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
        }
    }
}

struct SlotView: View {
    let slot: VisionSlotTemplate
    let rect: CGRect
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    
    private var placeholderImageName: String {
        let imageIndex = (slot.id % 8) + 1
        return "placeholder-\(imageIndex)"
    }
    
    var body: some View {
        ZStack {
            // Slot background
            Rectangle()
                .fill(slot.type == .image ? theme.accent.opacity(0.1) : theme.accentStrong.opacity(0.1))
                .overlay(
                    Rectangle()
                        .stroke(theme.accent.opacity(0.3), lineWidth: 2)
                )
                .cornerRadius(8)
            
            // Content based on slot type
            if slot.type == .image {
                Image(placeholderImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width - 8, height: rect.height - 8)
                    .clipped()
                    .cornerRadius(6)
            } else {
                Text("I am manifesting\nabundance")
                    .font(.appBody)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(8)
            }
            
            // Debug overlay
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("ID: \(slot.id)")
                            .font(.system(size: 8, weight: .bold))
                        Text(slot.type.rawValue)
                            .font(.system(size: 7))
                        Text("(\(Int(slot.cgRect.origin.x)),\(Int(slot.cgRect.origin.y)))")
                            .font(.system(size: 6))
                        Text("\(Int(slot.cgRect.width))×\(Int(slot.cgRect.height))")
                            .font(.system(size: 6))
                    }
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                }
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }
}

struct TemplateInfoView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Template Details")
                .font(.appSecondary)
                .foregroundColor(theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Grid Size", value: "\(Int(template.cgGridSize.width)) × \(Int(template.cgGridSize.height))")
                InfoRow(label: "Total Slots", value: "\(template.slots.count)")
                InfoRow(label: "Image Slots", value: "\(template.slots.filter { $0.type == .image }.count)")
                InfoRow(label: "Text Slots", value: "\(template.slots.filter { $0.type == .text }.count)")
            }
            .padding(16)
            .background(theme.secondary.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.appCaption)
                .foregroundColor(theme.textSecondary)
            Spacer()
            Text(value)
                .font(.appBody)
                .foregroundColor(theme.textPrimary)
        }
    }
}

#Preview {
    let sampleTemplate = VisionBoardTemplate(
        id: "preview",
        name: "Sample Template",
        gridSize: CodableSize(from: CGSize(width: 8, height: 8)),
        slots: [
            VisionSlotTemplate(id: 1, rect: CodableRect(from: CGRect(x: 0, y: 0, width: 4, height: 4)), type: .image),
            VisionSlotTemplate(id: 2, rect: CodableRect(from: CGRect(x: 4, y: 0, width: 4, height: 4)), type: .image),
            VisionSlotTemplate(id: 3, rect: CodableRect(from: CGRect(x: 0, y: 4, width: 4, height: 4)), type: .image),
            VisionSlotTemplate(id: 4, rect: CodableRect(from: CGRect(x: 4, y: 4, width: 4, height: 4)), type: .text)
        ],
        theme: nil
    )
    
    NavigationView {
        VisionBoardTemplateDetailView(template: sampleTemplate)
    }
}
