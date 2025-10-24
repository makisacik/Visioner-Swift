//
//  VisionBoardTemplateDetailView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct VisionBoardTemplateDetailView: View {
    let template: VisionBoardTemplate
    @StateObject private var visionBoardService = VisionBoardService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Template title
                Text(template.name)
                    .font(.appLogo)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                // Inspiring subtitle
                Text("Choose the frame for your dreams")
                    .font(.appSecondary)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Template visualization with proper aspect ratio
                TemplateVisualizationView(template: template)
                    .aspectRatio(template.cgGridSize.width / template.cgGridSize.height, contentMode: .fit)
                    .frame(maxHeight: 300) // Maximum height to prevent overly tall cards
                    .padding(.horizontal, 10)

                // Create board CTA - now properly below the image
                createBoardButton
                    .padding(.horizontal)

                // Template info
                TemplateInfoView(template: template)
                    .padding(.horizontal)

                // Debug details card
                DebugDetailsCard(template: template)
                    .padding(.horizontal)

                Spacer(minLength: 20)
            }
        }
        .background(theme.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Create Board Button

    private var createBoardButton: some View {
        NavigationLink(destination: createBoardDestination) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))

                Text("Create My Vision Board")
                    .font(.appButton)
            }
            .foregroundColor(theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(theme.accent)
            .cornerRadius(12)
            .shadow(color: theme.shadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var createBoardDestination: some View {
        let board = visionBoardService.createBoard(from: template, title: "\(template.name) Vision")
        return VisionBoardEditorView(board: board, template: template)
    }
}

struct TemplateVisualizationView: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let cellWidth = availableWidth / template.cgGridSize.width
            let cellHeight = cellWidth
            let totalHeight = cellHeight * template.cgGridSize.height
            
            ZStack {
                // Background
                Rectangle()
                    .fill(theme.background)
                
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
            .cornerRadius(16) // Apply corner radius to the entire board
            .clipped() // Ensure content doesn't overflow
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
            
            // Content based on slot type
            if slot.type == .image {
                Image(placeholderImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
            } else {
                Text("I am manifesting\nabundance")
                    .font(.appBody)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(4)
            }
            
            // Add separator lines around the slot
            Rectangle()
                .stroke(theme.shadow.opacity(0.2), lineWidth: 1)
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

struct DebugDetailsCard: View {
    let template: VisionBoardTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug Details")
                .font(.appSecondary)
                .foregroundColor(theme.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(template.slots) { slot in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Slot ID: \(slot.id)")
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Text(slot.type.rawValue)
                                .font(.system(size: 11))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(theme.accent.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        HStack {
                            Text("Position: (\(Int(slot.cgRect.origin.x)), \(Int(slot.cgRect.origin.y)))")
                                .font(.system(size: 10))
                            Spacer()
                            Text("Size: \(Int(slot.cgRect.width))×\(Int(slot.cgRect.height))")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(theme.textSecondary)
                    }
                    .padding(.vertical, 4)
                    
                    if slot.id != template.slots.last?.id {
                        Divider()
                            .background(theme.shadow.opacity(0.3))
                    }
                }
            }
            .padding(16)
            .background(theme.secondary.opacity(0.1))
            .cornerRadius(12)
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
