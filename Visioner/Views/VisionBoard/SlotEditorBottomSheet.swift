//
//  SlotEditorBottomSheet.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import PhotosUI

// MARK: - Soothing Background Model

struct SoothingBackground: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let gradient: LinearGradient
    let emoji: String
    
    // MARK: - Hashable & Equatable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(emoji)
    }
    
    static func == (lhs: SoothingBackground, rhs: SoothingBackground) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.emoji == rhs.emoji
    }

    static let backgrounds: [SoothingBackground] = [
        SoothingBackground(
            name: "Lavender Dreams",
            gradient: LinearGradient(
                colors: [Color(hex: "#E9A8D0"), Color(hex: "#D9C8F0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            emoji: "💜"
        ),
        SoothingBackground(
            name: "Golden Glow",
            gradient: LinearGradient(
                colors: [Color(hex: "#FFD89B"), Color(hex: "#19547B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            emoji: "✨"
        ),
        SoothingBackground(
            name: "Rose Quartz",
            gradient: LinearGradient(
                colors: [Color(hex: "#F8BBD9"), Color(hex: "#E8A3C7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            emoji: "🌹"
        ),
        SoothingBackground(
            name: "Ocean Breeze",
            gradient: LinearGradient(
                colors: [Color(hex: "#A8E6CF"), Color(hex: "#88D8C0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            emoji: "🌊"
        ),
        SoothingBackground(
            name: "Sunset Bliss",
            gradient: LinearGradient(
                colors: [Color(hex: "#FFB6C1"), Color(hex: "#FFA07A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            emoji: "🌅"
        ),
        SoothingBackground(
            name: "Moonlight",
            gradient: LinearGradient(
                colors: [Color(hex: "#C7CEEA"), Color(hex: "#B19CD9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            emoji: "🌙"
        )
    ]
}

/// Bottom sheet component for editing slot content (images or text)
struct SlotEditorBottomSheet: View {
    let slotType: SlotType
    let onDismiss: () -> Void
    let onSaveText: (String) -> Void
    let onRemoveContent: () -> Void
    let onImageSelected: (PhotosPickerItem) -> Void
    
    @State private var textInput = ""
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var selectedBackground: SoothingBackground?
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    if slotType == .image {
                        imageEditorContent
                    } else {
                        textEditorContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(
                // Blur background effect
                theme.background
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .overlay(
                // Success message overlay
                successMessageOverlay
            )
        }
    }
    
    // MARK: - Image Editor Content
    
    private var imageEditorContent: some View {
        VStack(spacing: 24) {
            // Header with inspiring microcopy
            VStack(spacing: 8) {
                Text("Add Your Vision")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
                
                Text("Choose an image that represents your dream")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))

            // Photo Library Section
            VStack(spacing: 12) {
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
                        showSuccessMessage = true
                        // Haptic feedback
                        HapticFeedbackService.shared.provideFeedback(.selection)
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            // Library Integration (Placeholder)
            VStack(spacing: 12) {
                Button(action: {}) {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .medium))
                        
                        Text("Choose from Library")
                            .font(.appButton)

                        Spacer()

                        Text("Coming Soon")
                            .font(.appCaption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.accentStrong.opacity(0.2))
                            .cornerRadius(6)
                    }
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.secondary.opacity(0.3))
                    .cornerRadius(12)
                }
                .disabled(true)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            // Soothing Backgrounds Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Soothing Backgrounds")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)

                Text("Pre-curated peaceful backgrounds")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(SoothingBackground.backgrounds) { background in
                        Button(action: {
                            selectedBackground = background
                            // Convert gradient to image data (placeholder for now)
                            // This would need actual implementation
                        }) {
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(background.gradient)
                                    .frame(height: 60)
                                    .overlay(
                                        Text(background.emoji)
                                            .font(.system(size: 20))
                                    )

                                Text(background.name)
                                    .font(.appCaption)
                                    .foregroundColor(theme.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        .scaleEffect(selectedBackground?.id == background.id ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedBackground?.id)
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            // Remove button
            Button(action: {
                onRemoveContent()
                // Haptic feedback
                HapticFeedbackService.shared.provideFeedback(.impact)
            }) {
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
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSuccessMessage)
    }
    
    // MARK: - Text Editor Content
    
    private var textEditorContent: some View {
        VStack(spacing: 24) {
            // Header with inspiring microcopy
            VStack(spacing: 8) {
                Text("Write Your Affirmation")
                    .font(.appSecondary)
                    .foregroundColor(theme.textPrimary)
                
                Text("Make it feel like you already have it")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))

            // Enhanced text editor with live preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Your affirmation:")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)

                ZStack(alignment: .topLeading) {
                    // Background with calm styling
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.background.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                    )

                    // Text editor
                    TextEditor(text: $textInput)
                        .font(.appBody)
                        .foregroundColor(theme.textPrimary)
                        .padding(16)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)

                    // Placeholder text
                    if textInput.isEmpty {
                        Text("I am worthy of all my dreams...")
                            .font(.appBody)
                            .foregroundColor(theme.textSecondary.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                            .allowsHitTesting(false)
                    }
                }
                .frame(minHeight: 120)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            // Affirming hints
            VStack(spacing: 8) {
                Text("Short, powerful, present tense")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary.opacity(0.8))
                    .italic()
                
                Text("Examples: 'I am abundant' • 'Success flows to me' • 'I am loved'")
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            
            // Action buttons with enhanced styling
            HStack(spacing: 12) {
                // Cancel button
                Button(action: {
                    onDismiss()
                    // Haptic feedback
                    HapticFeedbackService.shared.provideFeedback(.selection)
                }) {
                    Text("Cancel")
                        .font(.appButton)
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.secondary.opacity(0.3))
                        .cornerRadius(12)
                }
                
                // Save button
                Button(action: {
                    onSaveText(textInput)
                    showSuccessMessage = true
                    // Haptic feedback
                    HapticFeedbackService.shared.provideFeedback(.success)
                }) {
                    Text("Save Affirmation")
                        .font(.appButton)
                        .foregroundColor(theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.accent)
                        .cornerRadius(12)
                }
                .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSuccessMessage)
    }

    // MARK: - Success Message Overlay

    private var successMessageOverlay: some View {
        Group {
            if showSuccessMessage {
                VStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .medium))

                        Text(slotType == .image ? "Beautiful choice ✨" : "Affirmation saved ✨")
                            .font(.appButton)
                    }
                    .foregroundColor(theme.background)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(theme.accentStrong)
                    .cornerRadius(20)
                    .shadow(color: theme.shadow, radius: 8, x: 0, y: 4)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showSuccessMessage = false
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SlotEditorBottomSheet(
        slotType: .text,
        onDismiss: {},
        onSaveText: { _ in },
        onRemoveContent: {},
        onImageSelected: { _ in }
    )
}
