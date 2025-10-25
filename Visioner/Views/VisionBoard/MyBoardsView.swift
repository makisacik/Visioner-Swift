//
//  MyBoardsView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

/// View for displaying and managing saved vision boards
struct MyBoardsView: View {
    @StateObject private var viewModel = MyBoardsViewModel()
    @State private var showingContextMenu = false
    @State private var selectedBoardForMenu: VisionBoardEntity?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main background
                theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    headerView
                    
                    // Content
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.boards.isEmpty {
                        emptyStateView
                    } else {
                        boardsGridView
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Delete Board", isPresented: $viewModel.showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let board = viewModel.boardToDelete {
                        viewModel.deleteBoard(board)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this vision board? This action cannot be undone.")
            }
            .overlay(
                // Export progress overlay
                Group {
                    if viewModel.showingExportProgress {
                        ZStack {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                            
                            ExportProgressView(exportService: BoardExportService.shared)
                        }
                        .transition(.opacity)
                    }
                }
            )
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Vision Boards")
                        .font(.appLogo)
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Your dreams in progress")
                        .font(.appCaption)
                        .foregroundColor(theme.textSecondary)
                }
                
                Spacer()
                
                // Refresh button
                Button(action: {
                    viewModel.loadBoards()
                    // Haptic feedback
                    HapticFeedbackService.shared.provideFeedback(.selection)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(theme.accent)
                }
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
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(theme.accent)
            
            Text("Loading your vision boards...")
                .font(.appSecondary)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(theme.accent.opacity(0.6))
                
                VStack(spacing: 8) {
                    Text("No Vision Boards Yet")
                        .font(.appSecondary)
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Create your first vision board and start manifesting your dreams")
                        .font(.appCaption)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            NavigationLink(destination: VisionBoardGalleryView()) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Create Your First Board")
                        .font(.appButton)
                }
                .foregroundColor(theme.background)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(theme.accent)
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Boards Grid View
    
    private var boardsGridView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(viewModel.boards) { board in
                    BoardCardView(
                        board: board,
                        template: viewModel.getTemplate(for: board),
                        completionPercentage: viewModel.completionPercentage(for: board),
                        formattedDate: viewModel.formattedDate(for: board),
                        onTap: {
                            if let template = viewModel.getTemplate(for: board) {
                                // Navigate to editor
                                // This would need to be handled by the parent view
                            }
                        },
                        onLongPress: {
                            selectedBoardForMenu = board
                            showingContextMenu = true
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .contextMenu {
            if let board = selectedBoardForMenu {
                Button(action: {
                    if let template = viewModel.getTemplate(for: board) {
                        // Navigate to editor
                    }
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(action: {
                    viewModel.duplicateBoard(board)
                }) {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
                
                Button(action: {
                    Task {
                        await viewModel.exportBoard(board)
                    }
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                
                Divider()
                
                Button(action: {
                    viewModel.boardToDelete = board
                    viewModel.showingDeleteAlert = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Board Card View

struct BoardCardView: View {
    let board: VisionBoardEntity
    let template: VisionBoardTemplate?
    let completionPercentage: Double
    let formattedDate: String
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Board preview
            ZStack {
                if let template = template {
                    BoardPreviewView(board: board, template: template)
                        .aspectRatio(template.cgGridSize.width / template.cgGridSize.height, contentMode: .fit)
                        .frame(maxHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.background)
                                .shadow(color: theme.shadow, radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.shadow.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondary.opacity(0.3))
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(theme.textSecondary)
                                
                                Text("Template not found")
                                    .font(.appCaption)
                                    .foregroundColor(theme.textSecondary)
                            }
                        )
                }
                
                // Completion overlay
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 32, height: 32)
                            
                            Text("\(Int(completionPercentage * 100))%")
                                .font(.appCaption)
                                .fontWeight(.medium)
                                .foregroundColor(theme.textPrimary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(8)
            }
            
            // Board info
            VStack(alignment: .leading, spacing: 4) {
                Text(board.title ?? "Untitled Board")
                    .font(.appSecondary)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(2)
                
                Text(formattedDate)
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                
                // Progress bar
                ProgressView(value: completionPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accent))
                    .frame(height: 4)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.shadow.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {
            onLongPress()
        })
    }
}

// MARK: - Board Preview View

struct BoardPreviewView: View {
    let board: VisionBoardEntity
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
                    
                    let slotContent = board.slotsArray.first { $0.id == slot.id }
                    
                    PreviewSlotView(
                        slot: slot,
                        slotContent: slotContent,
                        rect: rect
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
        }
    }
}

// MARK: - Preview Slot View

struct PreviewSlotView: View {
    let slot: VisionSlotTemplate
    let slotContent: SlotContentEntity?
    let rect: CGRect
    
    private var hasContent: Bool {
        guard let content = slotContent else { return false }
        return content.imageData != nil || (content.text != nil && !content.text!.isEmpty && content.text != "+ Write affirmation")
    }
    
    var body: some View {
        ZStack {
            // Slot background
            Rectangle()
                .fill(backgroundFill)
                .overlay(
                    Rectangle()
                        .stroke(theme.shadow.opacity(0.3), lineWidth: 0.5)
                )
            
            // Content
            if hasContent {
                contentView
            } else {
                placeholderView
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }
    
    private var backgroundFill: Color {
        if hasContent {
            return theme.background
        } else {
            return slot.type == .image ?
                theme.accent.opacity(0.1) :
                theme.accentStrong.opacity(0.1)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if slot.type == .image, let imageData = slotContent?.imageData {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
            }
        } else if slot.type == .text, let text = slotContent?.text, !text.isEmpty, text != "+ Write affirmation" {
            Text(text)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding(2)
        }
    }
    
    private var placeholderView: some View {
        Image(systemName: slot.type == .image ? "photo" : "text.quote")
            .font(.system(size: 8, weight: .light))
            .foregroundColor(theme.textSecondary.opacity(0.4))
    }
}

// MARK: - Preview

#Preview {
    MyBoardsView()
}
