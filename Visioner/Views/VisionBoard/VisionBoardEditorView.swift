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
    @State private var showFocusMode = false
    @State private var focusedSlot: VisionSlotTemplate?
    @State private var focusedSlotContent: SlotContentEntity?
    @StateObject private var exportService = BoardExportService.shared
    @State private var showShareSheet = false
    @State private var exportedImage: UIImage?
    @State private var showThemeSelector = false
    @State private var showQuoteSelector = false
    
    init(board: VisionBoardEntity, template: VisionBoardTemplate) {
        self._viewModel = StateObject(wrappedValue: VisionBoardEditorViewModel(board: board, template: template))
    }
    
    var body: some View {
        ZStack {
            // Background
            theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Board canvas
                boardCanvasView
                    .padding(.horizontal, 16)
                
                Spacer()
            }
            
            
            // Focus mode overlay
            if showFocusMode, let focusedSlot = focusedSlot {
                FocusModeOverlay(
                    slot: focusedSlot,
                    slotContent: focusedSlotContent,
                    rect: CGRect(x: 0, y: 0, width: 200, height: 200), // Placeholder rect
                    onDismiss: {
                        showFocusMode = false
                        self.focusedSlot = nil
                        self.focusedSlotContent = nil
                    }
                )
                .transition(.opacity)
            }
            
            // Export progress overlay
            if exportService.isExporting {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ExportProgressView(exportService: exportService)
                }
                .transition(.opacity)
            }
            
            // Export success overlay
            if exportService.showExportSuccess {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ExportSuccessView(exportService: exportService)
                }
                .transition(.opacity)
            }
        }
        .navigationBarHidden(false)
        .toolbar {
            
            ToolbarItemGroup(placement: .principal) {
                VStack(spacing: 2) {
                    Text(viewModel.board.title ?? "Vision Board")
                        .font(.appSecondary)
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Your vision is taking shape")
                        .font(.appCaption)
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // Enhance button
                    Button(action: {
                        showThemeSelector = true
                    }) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(theme.accent)
                    }
                    
                    // Export button
                    Button(action: {
                        Task {
                            await exportBoard()
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(theme.accent)
                    }
                    .disabled(exportService.isExporting)
                }
            }
            
            // Slot editing toolbar (appears when slot is selected)
            if let selectedSlotId = viewModel.selectedSlotId,
               let slotTemplate = viewModel.selectedSlotTemplate {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack(spacing: 20) {
                        // Font tool (for text slots)
                        if slotTemplate.type == .text {
                            Button(action: {
                                // TODO: Implement font picker
                                HapticFeedbackService.shared.provideFeedback(.selection)
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "textformat")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Font")
                                        .font(.appCaption)
                                }
                                .foregroundColor(theme.textPrimary)
                            }
                        }
                        
                        // Color tool
                        Button(action: {
                            // TODO: Implement color picker
                            HapticFeedbackService.shared.provideFeedback(.selection)
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "paintpalette")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Color")
                                    .font(.appCaption)
                            }
                            .foregroundColor(theme.textPrimary)
                        }
                        
                        // Filter tool (for image slots)
                        if slotTemplate.type == .image {
                            Button(action: {
                                // TODO: Implement filter picker
                                HapticFeedbackService.shared.provideFeedback(.selection)
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "camera.filters")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Filter")
                                        .font(.appCaption)
                                }
                                .foregroundColor(theme.textPrimary)
                            }
                        }
                        
                        // Alignment tool (for text slots)
                        if slotTemplate.type == .text {
                            Button(action: {
                                // TODO: Implement alignment picker
                                HapticFeedbackService.shared.provideFeedback(.selection)
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Align")
                                        .font(.appCaption)
                                }
                                .foregroundColor(theme.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = exportedImage {
                ShareSheet(activityItems: [
                    image,
                    "✨ My vision is coming to life! #MyVisionFor2026 #Visioner"
                ])
            }
        }
        .sheet(isPresented: $showThemeSelector) {
            ThemeSelectorView(
                onThemeSelected: { theme in
                    applyThemeToBoard(theme)
                },
                onQuoteSelected: {
                    showQuoteSelector = true
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showQuoteSelector) {
            QuoteSelectorView(
                onQuoteSelected: { quote in
                    addQuoteToBoard(quote)
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.selectedSlotForSheet) { slot in
            let slotType = SlotType(rawValue: slot.slotType ?? "image") ?? .image
            SlotEditorBottomSheet(
                slotType: slotType,
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
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
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
                        },
                        onDoubleTap: {
                            focusedSlot = slotTemplate
                            focusedSlotContent = slotContent
                            showFocusMode = true
                        }
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
        }
    }
    
    // MARK: - Export Function
    
    private func exportBoard() async {
        let image = await exportService.exportBoard(viewModel.board, template: viewModel.template)
        
        if let image = image {
            // Save to Photos
            let saved = await exportService.saveToPhotos(image)
            
            if saved {
                // Also prepare for sharing
                exportedImage = image
                showShareSheet = true
            }
        }
    }
    
    // MARK: - Theme Functions
    
    private func applyThemeToBoard(_ theme: BoardTheme) {
        // Apply theme to all text slots
        for slot in viewModel.board.slotsArray {
            if slot.slotType == "text" {
                slot.colorHex = theme.textColor.toHex()
                slot.fontName = theme.fontName
            }
        }
        
        // Save changes
        viewModel.refreshBoard()
        
        // Haptic feedback
        HapticFeedbackService.shared.provideFeedback(.success)
    }
    
    private func addQuoteToBoard(_ quote: String) {
        // Add quote to board title or as a special slot
        // This is a placeholder implementation
        viewModel.board.title = "\(viewModel.board.title ?? "Vision Board") - \(quote)"
        
        // Save changes
        viewModel.refreshBoard()
        
        // Haptic feedback
        HapticFeedbackService.shared.provideFeedback(.success)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
