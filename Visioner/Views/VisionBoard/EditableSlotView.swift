//
//  EditableSlotView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import CoreData

/// Individual slot component that displays content or placeholder state
struct EditableSlotView: View {
    let slot: VisionSlotTemplate
    let slotContent: SlotContentEntity?
    let rect: CGRect
    let isSelected: Bool
    let onTap: () -> Void
    let onDoubleTap: (() -> Void)?
    
    @State private var isPressed = false
    @State private var showFocusMode = false
    @State private var showBloom = false
    @State private var showSuccessMessage = false
    
    init(slot: VisionSlotTemplate, slotContent: SlotContentEntity?, rect: CGRect, isSelected: Bool, onTap: @escaping () -> Void, onDoubleTap: (() -> Void)? = nil) {
        self.slot = slot
        self.slotContent = slotContent
        self.rect = rect
        self.isSelected = isSelected
        self.onTap = onTap
        self.onDoubleTap = onDoubleTap
    }
    
    var body: some View {
        ZStack {
            // Slot background
            Rectangle()
                .fill(backgroundFill)
                .overlay(
                    Rectangle()
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            
            // Content based on slot type and state
            if let content = slotContent, hasContent {
                contentView(for: content)
            } else {
                placeholderView
            }
            
            // Selection indicator
            if isSelected {
                selectionOverlay
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: hasContent)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .gesture(
            TapGesture(count: 2)
                .onEnded {
                    onDoubleTap?()
                    // Haptic feedback for double tap
                    HapticFeedbackService.shared.provideFeedback(.focus)
                }
        )
    }
    
    // MARK: - Computed Properties
    
    private var effectiveSlotType: SlotType {
        // Use slot content type if available, otherwise use template type
        if let slotContent = slotContent, let slotTypeString = slotContent.slotType {
            return SlotType(rawValue: slotTypeString) ?? slot.type
        }
        return slot.type
    }
    
    private var hasContent: Bool {
        guard let content = slotContent else { return false }
        return content.imageData != nil || (content.text != nil && !content.text!.isEmpty)
    }
    
    private var backgroundFill: Color {
        if hasContent {
            return theme.background
        } else {
            return effectiveSlotType == .image ? 
                theme.accent.opacity(0.1) : 
                theme.accentStrong.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return theme.accentStrong
        } else if hasContent {
            return theme.shadow.opacity(0.3)
        } else {
            return theme.accent.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected ? 2.0 : 1.0
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private func contentView(for content: SlotContentEntity) -> some View {
        if slot.type == .image, let imageData = content.imageData {
            imageContentView(imageData: imageData)
        } else if slot.type == .text, let text = content.text, !text.isEmpty {
            textContentView(text: text, style: content)
        } else {
            placeholderView
        }
    }
    
    private func imageContentView(imageData: Data) -> some View {
        Group {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .clipped()
            } else {
                placeholderView
            }
        }
    }
    
    private func textContentView(text: String, style: SlotContentEntity) -> some View {
        Text(text)
            .font(.appBody)
            .foregroundColor(theme.textPrimary)
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var placeholderView: some View {
        ZStack {
            VStack(spacing: 8) {
                Image(systemName: effectiveSlotType == .image ? "photo" : "text.quote")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(theme.textSecondary.opacity(0.6))
                
                Text(placeholderText)
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            // Bloom effect overlay
            if showBloom {
                bloomOverlay
            }
            
            // Success message overlay
            if showSuccessMessage {
                successMessageOverlay
            }
        }
        .overlay(
            Rectangle()
                .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                .opacity(0.5)
        )
    }
    
    private var placeholderText: String {
        if hasContent {
            return effectiveSlotType == .image ? "Image" : "Text"
        } else {
            return effectiveSlotType == .image ? "+ Add image" : "+ Write affirmation"
        }
    }
    
    private var selectionOverlay: some View {
        Rectangle()
            .stroke(theme.accentStrong, lineWidth: 2)
            .background(
                Rectangle()
                    .fill(theme.accentStrong.opacity(0.1))
            )
            .frame(width: rect.width, height: rect.height)
    }
    
    // MARK: - Animation Overlays
    
    private var bloomOverlay: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        theme.accent.opacity(0.4),
                        theme.accent.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: rect.width / 2
                )
            )
            .frame(width: rect.width, height: rect.height)
            .scaleEffect(showBloom ? 1.2 : 0.8)
            .opacity(showBloom ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showBloom)
    }
    
    private var successMessageOverlay: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                
                Text("Beautiful choice ✨")
                    .font(.appCaption)
            }
            .foregroundColor(theme.background)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.accentStrong)
            .scaleEffect(showSuccessMessage ? 1.0 : 0.8)
            .opacity(showSuccessMessage ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccessMessage)
            
            Spacer()
        }
    }
    
    // MARK: - Animation Functions
    
    private func triggerBloomAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            showBloom = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showBloom = false
            }
        }
    }
    
    private func showSuccessFeedback() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccessMessage = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleSlot = VisionSlotTemplate(
        id: 1,
        rect: CodableRect(from: CGRect(x: 0, y: 0, width: 4, height: 4)),
        type: .image
    )
    
    // Create a sample Core Data entity for preview
    let context = PersistenceController.preview.container.viewContext
    let sampleContent = SlotContentEntity(context: context)
    sampleContent.id = 1
    sampleContent.slotType = "image"
    sampleContent.imageData = nil
    sampleContent.text = nil
    sampleContent.fontName = "Nunito Sans"
    sampleContent.fontSize = 16.0
    sampleContent.colorHex = "#2B1F4A"
    
    return EditableSlotView(
        slot: sampleSlot,
        slotContent: sampleContent,
        rect: CGRect(x: 0, y: 0, width: 200, height: 200),
        isSelected: false,
        onTap: {},
        onDoubleTap: nil
    )
    .frame(width: 200, height: 200)
    .background(Color.gray.opacity(0.1))
}
