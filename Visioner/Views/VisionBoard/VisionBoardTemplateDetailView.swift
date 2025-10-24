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
                UnifiedTemplateVisualizationView(template: template)
                    .aspectRatio(template.cgGridSize.width / template.cgGridSize.height, contentMode: .fit)
                    .frame(maxHeight: 400) // Increased height to show all slots
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

// MARK: - Unified Template Visualization (shared between gallery and detail views)

struct UnifiedTemplateVisualizationView: View {
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
                    
                    UnifiedSlotView(
                        slot: slot,
                        rect: rect,
                        template: template
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
            .cornerRadius(16) // Apply corner radius to the entire board
            .clipped() // Ensure content doesn't overflow
        }
    }
}

// MARK: - Unified Slot View (shared between gallery and detail views)

struct UnifiedSlotView: View {
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
                // Image slot with template image asset
                Image(placeholderImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
                    .overlay(
                        // Subtle overlay to show it's a preview
                        Rectangle()
                            .fill(theme.primary.opacity(0.1))
                    )
            } else {
                // Text slot with sample affirmation
                Rectangle()
                    .fill(theme.accentStrong.opacity(0.1))
                    .overlay(
                        VStack(spacing: 4) {
                            Text(sampleAffirmation(for: slot.id))
                                .font(.appBody)
                                .foregroundColor(theme.accentStrong)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(6)
                    )
            }
            
            // Add separator lines around the slot
            Rectangle()
                .stroke(theme.shadow.opacity(0.3), lineWidth: 1)
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
            "I am blessed",
            "I am powerful",
            "Joy fills my heart",
            "I attract miracles",
            "Peace flows through me",
            "I am unstoppable",
            "Happiness is my birthright",
            "I manifest my desires",
            "I am loved deeply",
            "Wealth comes to me easily",
            "I am healthy and strong",
            "My future is bright",
            "I am exactly where I need to be"
        ]
        return affirmations[slotId % affirmations.count]
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
                                .font(.appCaption)
                                .fontWeight(.bold)
                            Spacer()
                            Text(slot.type.rawValue)
                                .font(.appCaption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(theme.accent.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        HStack {
                            Text("Position: (\(Int(slot.cgRect.origin.x)), \(Int(slot.cgRect.origin.y)))")
                                .font(.appCaption)
                            Spacer()
                            Text("Size: \(Int(slot.cgRect.width))×\(Int(slot.cgRect.height))")
                                .font(.appCaption)
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
