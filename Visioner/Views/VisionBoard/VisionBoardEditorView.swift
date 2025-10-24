//
//  VisionBoardEditorView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

/// Main vision board editor view with grid layout and slot editing
struct VisionBoardEditorView: View {
    @StateObject private var viewModel: VisionBoardEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(board: VisionBoardEntity, template: VisionBoardTemplate) {
        self._viewModel = StateObject(wrappedValue: VisionBoardEditorViewModel(board: board, template: template))
    }
    
    var body: some View {
        ZStack {
            // Background
            theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Board canvas
                boardCanvasView
                    .padding(.horizontal, 16)
                
                Spacer()
            }
            
            // Bottom sheet overlay
            if viewModel.showingBottomSheet {
                bottomSheetOverlay
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(theme.textPrimary)
            }
            
            Spacer()
            
            // Title
            VStack(spacing: 2) {
                Text(viewModel.board.title ?? "Vision Board")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
                
                Text("Your vision is taking shape")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
            }
            
            Spacer()
            
            // Save indicator
            if viewModel.isSaving {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(theme.accent)
            } else {
                // Invisible spacer to balance the back button
                Color.clear
                    .frame(width: 18, height: 18)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Board Canvas View
    
    private var boardCanvasView: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let cellWidth = availableWidth / viewModel.template.cgGridSize.width
            let cellHeight = cellWidth // Make cells square for proper proportions
            let totalHeight = cellHeight * viewModel.template.cgGridSize.height
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.background)
                    .shadow(color: theme.shadow, radius: 8, x: 0, y: 4)
                
                // Grid slots
                ForEach(viewModel.template.slots) { slotTemplate in
                    let rect = CGRect(
                        x: slotTemplate.cgRect.origin.x * cellWidth,
                        y: slotTemplate.cgRect.origin.y * cellHeight,
                        width: slotTemplate.cgRect.width * cellWidth,
                        height: slotTemplate.cgRect.height * cellHeight
                    )
                    
                    let slotContent = viewModel.board.slotsArray.first { $0.id == slotTemplate.id }
                    let isSelected = viewModel.selectedSlotId == slotTemplate.id
                    
                    EditableSlotView(
                        slot: slotTemplate,
                        slotContent: slotContent,
                        rect: rect,
                        isSelected: isSelected,
                        onTap: {
                            viewModel.selectSlot(slotTemplate.id)
                        }
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
        }
    }
    
    // MARK: - Bottom Sheet Overlay
    
    private var bottomSheetOverlay: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissBottomSheet()
                }
            
            VStack {
                Spacer()
                
                if let selectedSlot = viewModel.selectedSlot {
                    let slotType = SlotType(rawValue: selectedSlot.slotType ?? "image") ?? .image
                    SlotEditorBottomSheet(
                        slotType: slotType,
                        isPresented: viewModel.showingBottomSheet,
                        onDismiss: {
                            viewModel.dismissBottomSheet()
                        },
                        onSaveText: { text in
                            viewModel.editingText = text
                            viewModel.saveTextContent()
                        },
                        onRemoveContent: {
                            viewModel.removeSlotContent()
                        },
                        onImageSelected: { item in
                            viewModel.selectedImageItem = item
                        }
                    )
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showingBottomSheet)
    }
}

// MARK: - Preview

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
    
    let sampleBoard = VisionBoardService.shared.createBoard(from: sampleTemplate, title: "My Dream Life")
    
    NavigationView {
        VisionBoardEditorView(board: sampleBoard, template: sampleTemplate)
    }
}
