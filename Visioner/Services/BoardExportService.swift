//
//  BoardExportService.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import Photos
import UIKit
import Combine

/// Service for exporting vision boards as images and sharing them
final class BoardExportService: ObservableObject {
    static let shared = BoardExportService()
    
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var showExportSuccess = false
    
    private init() {}
    
    // MARK: - Export Methods
    
    /// Export a vision board as a high-quality image
    func exportBoard(_ board: VisionBoardEntity, template: VisionBoardTemplate, size: CGSize? = nil) async -> UIImage? {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
        }
        
        // Simulate progress updates
        for i in 1...10 {
            await MainActor.run {
                exportProgress = Double(i) / 10.0
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Create the board image with actual board dimensions
        let boardSize = size ?? CGSize(width: template.cgGridSize.width * 200, height: template.cgGridSize.height * 200)
        let boardImage = await createBoardImage(board: board, template: template, size: boardSize)
        
        await MainActor.run {
            isExporting = false
            exportProgress = 1.0
        }
        
        return boardImage
    }
    
    /// Save image to Photos library
    func saveToPhotos(_ image: UIImage) async -> Bool {
        await MainActor.run {
            isExporting = true
        }
        
        let result = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        continuation.resume(returning: success)
                    }
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
        
        await MainActor.run {
            isExporting = false
            if result {
                showExportSuccess = true
                // Auto-hide success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.showExportSuccess = false
                }
            }
        }
        
        return result
    }
    
    /// Create share sheet for the image
    func createShareSheet(for image: UIImage) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [
                image,
                generateShareText()
            ],
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return activityViewController
    }
    
    // MARK: - Private Methods
    
    private func createBoardImage(board: VisionBoardEntity, template: VisionBoardTemplate, size: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let renderer = ImageRenderer(content: CleanBoardExportView(board: board, template: template))
            renderer.scale = 3.0 // High resolution
            // Use the actual board dimensions for tight cropping
            let boardWidth = template.cgGridSize.width * 200 // Base cell size
            let boardHeight = template.cgGridSize.height * 200
            let exportSize = CGSize(width: boardWidth, height: boardHeight)
            renderer.proposedSize = .init(exportSize)
            
            if let uiImage = renderer.uiImage {
                // Convert to opaque image to avoid alpha channel issues
                let opaqueImage = createOpaqueImage(from: uiImage)
                continuation.resume(returning: opaqueImage)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
    /// Convert an image with alpha channel to an opaque image to optimize file size and memory usage
    private func createOpaqueImage(from image: UIImage) -> UIImage {
        let size = image.size
        let scale = image.scale
        
        // Create a graphics context with opaque background
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        defer { UIGraphicsEndImageContext() }
        
        // Fill with theme background color to match the vision board
        let themeBackgroundColor = UIColor(ThemeManager.shared.currentTheme.background)
        themeBackgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Draw the original image on top
        image.draw(in: CGRect(origin: .zero, size: size))
        
        // Get the opaque image
        guard let opaqueImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return image // Fallback to original if conversion fails
        }
        
        return opaqueImage
    }
    
    private func generateShareText() -> String {
        let messages = [
            "✨ My vision is coming to life! #MyVisionFor2026 #Visioner",
            "🌟 Manifesting my dreams with Visioner #VisionBoard #Dreams",
            "💫 Creating my reality, one vision at a time #Visioner #Manifestation",
            "🌈 My vision board is ready to manifest! #Visioner #Dreams",
            "✨ Turning dreams into reality with Visioner #VisionBoard"
        ]
        
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - Clean Board Export View (without title/navigation)

struct CleanBoardExportView: View {
    let board: VisionBoardEntity
    let template: VisionBoardTemplate
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let cellWidth = availableWidth / template.cgGridSize.width
            let cellHeight = cellWidth
            let totalHeight = cellHeight * template.cgGridSize.height
            
            // Calculate the actual bounds of all slots to crop tightly
            let slotBounds = calculateSlotBounds(template: template, cellWidth: cellWidth, cellHeight: cellHeight)
            
            ZStack {
                // Clean background - just the board content
                Rectangle()
                    .fill(theme.background)
                    .shadow(color: theme.shadow, radius: 8, x: 0, y: 4)
                
                // Grid slots
                ForEach(template.slots) { slotTemplate in
                    let rect = CGRect(
                        x: slotTemplate.cgRect.origin.x * cellWidth,
                        y: slotTemplate.cgRect.origin.y * cellHeight,
                        width: slotTemplate.cgRect.width * cellWidth,
                        height: slotTemplate.cgRect.height * cellHeight
                    )
                    
                    let slotContent = board.slotsArray.first { $0.id == slotTemplate.id }
                    
                    ExportSlotView(
                        slot: slotTemplate,
                        slotContent: slotContent,
                        rect: rect
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
            .clipped() // Crop to exact content bounds
        }
        .frame(width: template.cgGridSize.width * 200, height: template.cgGridSize.height * 200) // Match actual board dimensions
    }
    
    // Calculate the tight bounds of all slots
    private func calculateSlotBounds(template: VisionBoardTemplate, cellWidth: CGFloat, cellHeight: CGFloat) -> CGRect {
        var minX: CGFloat = .infinity
        var minY: CGFloat = .infinity
        var maxX: CGFloat = -.infinity
        var maxY: CGFloat = -.infinity
        
        for slot in template.slots {
            let rect = CGRect(
                x: slot.cgRect.origin.x * cellWidth,
                y: slot.cgRect.origin.y * cellHeight,
                width: slot.cgRect.width * cellWidth,
                height: slot.cgRect.height * cellHeight
            )
            
            minX = min(minX, rect.minX)
            minY = min(minY, rect.minY)
            maxX = max(maxX, rect.maxX)
            maxY = max(maxY, rect.maxY)
        }
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

// MARK: - Board Export View (with title - for previews)

struct BoardExportView: View {
    let board: VisionBoardEntity
    let template: VisionBoardTemplate
    
    var body: some View {
        ZStack {
            // Background
            theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Board title
                Text(board.title ?? "My Vision Board")
                    .font(.appLogo)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Board content
                boardContentView
                
                // Inspirational quote
                Text("Your vision is taking shape ✨")
                    .font(.appSecondary)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
        }
    }
    
    private var boardContentView: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let cellWidth = availableWidth / template.cgGridSize.width
            let cellHeight = cellWidth
            let totalHeight = cellHeight * template.cgGridSize.height
            
            ZStack {
                // Background
                Rectangle()
                    .fill(theme.background)
                    .shadow(color: theme.shadow, radius: 20, x: 0, y: 10)
                
                // Grid slots
                ForEach(template.slots) { slotTemplate in
                    let rect = CGRect(
                        x: slotTemplate.cgRect.origin.x * cellWidth,
                        y: slotTemplate.cgRect.origin.y * cellHeight,
                        width: slotTemplate.cgRect.width * cellWidth,
                        height: slotTemplate.cgRect.height * cellHeight
                    )
                    
                    let slotContent = board.slotsArray.first { $0.id == slotTemplate.id }
                    
                    ExportSlotView(
                        slot: slotTemplate,
                        slotContent: slotContent,
                        rect: rect
                    )
                }
            }
            .frame(width: availableWidth, height: totalHeight)
        }
        .frame(height: 400) // Fixed height for export
    }
}

// MARK: - Export Slot View

struct ExportSlotView: View {
    let slot: VisionSlotTemplate
    let slotContent: SlotContentEntity?
    let rect: CGRect
    
    var body: some View {
        ZStack {
            // Slot background
            Rectangle()
                .fill(backgroundFill)
                .overlay(
                    Rectangle()
                        .stroke(theme.shadow.opacity(0.2), lineWidth: 1)
                )
            
            // Content
            if let content = slotContent, hasContent {
                contentView(for: content)
            } else {
                placeholderView
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }
    
    private var hasContent: Bool {
        guard let content = slotContent else { return false }
        return content.imageData != nil || (content.text != nil && !content.text!.isEmpty)
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
    private func contentView(for content: SlotContentEntity) -> some View {
        if slot.type == .image, let imageData = content.imageData {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
            } else {
                placeholderView
            }
        } else if slot.type == .text, let text = content.text, !text.isEmpty {
            Text(text)
                .font(.appBody)
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: slot.type == .image ? "photo" : "text.quote")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(theme.textSecondary.opacity(0.6))
            
            Text(placeholderText)
                .font(.appCaption)
                .foregroundColor(theme.textSecondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var placeholderText: String {
        slot.type == .image ? "+ Add image" : "+ Write affirmation"
    }
}

// MARK: - Export Progress View

struct ExportProgressView: View {
    @ObservedObject var exportService: BoardExportService
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Rendering your vision...")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
                
                ProgressView(value: exportService.exportProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accent))
                    .frame(width: 200)
                
                Text("\(Int(exportService.exportProgress * 100))%")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: theme.shadow, radius: 20, x: 0, y: 10)
        )
    }
    
}

// MARK: - Export Success View

struct ExportSuccessView: View {
    @ObservedObject var exportService: BoardExportService
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(theme.accent)
            
            Text("Saved to Photos ✨")
                .font(.appSecondary)
                .foregroundColor(theme.textPrimary)
            
            Text("Your vision is now alive")
                .font(.appCaption)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: theme.shadow, radius: 20, x: 0, y: 10)
        )
        .scaleEffect(exportService.showExportSuccess ? 1.0 : 0.8)
        .opacity(exportService.showExportSuccess ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: exportService.showExportSuccess)
    }
}
