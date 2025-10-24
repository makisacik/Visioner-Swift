//
//  SlotEditorBottomSheet.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import PhotosUI

/// Bottom sheet component for editing slot content (images or text)
struct SlotEditorBottomSheet: View {
    let slotType: SlotType
    let isPresented: Bool
    let onDismiss: () -> Void
    let onSaveText: (String) -> Void
    let onRemoveContent: () -> Void
    let onImageSelected: (PhotosPickerItem) -> Void
    
    @State private var textInput = ""
    @State private var selectedImageItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(theme.textSecondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Content based on slot type
            if slotType == .image {
                imageEditorContent
            } else {
                textEditorContent
            }
            
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.secondary.opacity(0.95))
                .background(.ultraThinMaterial)
        )
        .frame(maxHeight: 400)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPresented)
    }
    
    // MARK: - Image Editor Content
    
    private var imageEditorContent: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Add Your Vision")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
                
                Text("Choose an image that represents your dream")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Image picker button
            PhotosPicker(
                selection: $selectedImageItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20, weight: .medium))
                    
                    Text("Choose from Photos")
                        .font(.appButton)
                }
                .foregroundColor(theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.accent)
                .cornerRadius(12)
            }
            .onChange(of: selectedImageItem) { newItem in
                if let newItem = newItem {
                    onImageSelected(newItem)
                }
            }
            
            // Remove button
            Button(action: onRemoveContent) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Remove Image")
                        .font(.appButton)
                }
                .foregroundColor(theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(theme.secondary.opacity(0.3))
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Text Editor Content
    
    private var textEditorContent: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Write Your Affirmation")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
                
                Text("Make it feel like you already have it")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Text editor
            VStack(alignment: .leading, spacing: 8) {
                Text("Your affirmation:")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                
                TextEditor(text: $textInput)
                    .font(.appBody)
                    .foregroundColor(theme.textPrimary)
                    .padding(12)
                    .background(theme.background.opacity(0.5))
                    .cornerRadius(10)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Hint text
            Text("Short, powerful, present tense")
                .font(.appCaption)
                .foregroundColor(theme.textSecondary.opacity(0.8))
                .italic()
            
            // Action buttons
            HStack(spacing: 12) {
                // Cancel button
                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.appButton)
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(theme.secondary.opacity(0.3))
                        .cornerRadius(10)
                }
                
                // Save button
                Button(action: {
                    onSaveText(textInput)
                }) {
                    Text("Save Affirmation")
                        .font(.appButton)
                        .foregroundColor(theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(theme.accent)
                        .cornerRadius(10)
                }
                .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        
        SlotEditorBottomSheet(
            slotType: .text,
            isPresented: true,
            onDismiss: {},
            onSaveText: { _ in },
            onRemoveContent: {},
            onImageSelected: { _ in }
        )
    }
    .background(Color.gray.opacity(0.1))
    .ignoresSafeArea()
}
