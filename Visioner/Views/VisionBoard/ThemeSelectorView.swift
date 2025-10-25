//
//  ThemeSelectorView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

// MARK: - Board Theme Model

struct BoardTheme: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let textColor: Color
    let fontName: String
    let emoji: String
    let description: String
    
    // MARK: - Hashable & Equatable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(fontName)
        hasher.combine(emoji)
        hasher.combine(description)
    }
    
    static func == (lhs: BoardTheme, rhs: BoardTheme) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.fontName == rhs.fontName && lhs.emoji == rhs.emoji && lhs.description == rhs.description
    }
    
    static let themes: [BoardTheme] = [
        BoardTheme(
            name: "Rose Quartz",
            textColor: Color(hex: "#E8A3C7"),
            fontName: AppFontName.playfairRegular,
            emoji: "🌹",
            description: "Soft and nurturing"
        ),
        BoardTheme(
            name: "Golden Glow",
            textColor: Color(hex: "#FFD89B"),
            fontName: AppFontName.frauncesSemiBold,
            emoji: "✨",
            description: "Warm and abundant"
        ),
        BoardTheme(
            name: "Lavender Peace",
            textColor: Color(hex: "#D9C8F0"),
            fontName: AppFontName.nunitoSans,
            emoji: "💜",
            description: "Calm and serene"
        ),
        BoardTheme(
            name: "Ocean Breeze",
            textColor: Color(hex: "#A8E6CF"),
            fontName: AppFontName.interLight,
            emoji: "🌊",
            description: "Fresh and flowing"
        ),
        BoardTheme(
            name: "Sunset Bliss",
            textColor: Color(hex: "#FFB6C1"),
            fontName: AppFontName.playfairRegular,
            emoji: "🌅",
            description: "Romantic and dreamy"
        ),
        BoardTheme(
            name: "Moonlight",
            textColor: Color(hex: "#C7CEEA"),
            fontName: AppFontName.interMedium,
            emoji: "🌙",
            description: "Mystical and wise"
        )
    ]
}

/// Theme selector view for applying color themes to vision boards
struct ThemeSelectorView: View {
    let onThemeSelected: (BoardTheme) -> Void
    let onQuoteSelected: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme: BoardTheme?
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Enhance Your Vision")
                            .font(.appSecondary)
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Choose a theme that resonates with your dreams")
                            .font(.appCaption)
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Theme grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(BoardTheme.themes) { boardTheme in
                            ThemeCardView(
                                theme: boardTheme,
                                isSelected: selectedTheme?.id == boardTheme.id,
                                onTap: {
                                    selectedTheme = boardTheme
                                    // Haptic feedback
                                    HapticFeedbackService.shared.provideFeedback(.selection)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quote section
                    VStack(spacing: 12) {
                        Text("Add Inspiration")
                            .font(.appSecondary)
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Include an uplifting quote to your board")
                            .font(.appCaption)
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            onQuoteSelected()
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "quote.bubble")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Add Inspirational Quote")
                                    .font(.appButton)
                            }
                            .foregroundColor(theme.background)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(theme.accent)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        if let theme = selectedTheme {
                            onThemeSelected(theme)
                            dismiss()
                        }
                    }
                    .foregroundColor(theme.accent)
                    .disabled(selectedTheme == nil)
                }
            }
        }
    }
}

// MARK: - Theme Card View

struct ThemeCardView: View {
    let theme: BoardTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Theme preview
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.textColor.opacity(0.1))
                    .frame(height: 80)
                
                VStack(spacing: 8) {
                    Text(theme.emoji)
                        .font(.system(size: 24))
                    
                    Text("Sample Text")
                        .font(.custom(theme.fontName, size: 14))
                        .foregroundColor(theme.textColor)
                        .fontWeight(.medium)
                }
            }
            
            // Theme info
            VStack(spacing: 4) {
                Text(theme.name)
                    .font(.appSecondary)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                
                Text(theme.description)
                    .font(.appCaption)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? theme.accent : theme.shadow.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Quote Selector View

struct QuoteSelectorView: View {
    let onQuoteSelected: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuote: String?
    
    private let inspirationalQuotes = [
        "Your vision will become clear only when you can look into your own heart.",
        "The future belongs to those who believe in the beauty of their dreams.",
        "What you think, you become. What you feel, you attract. What you imagine, you create.",
        "The only impossible journey is the one you never begin.",
        "Dream big and dare to fail.",
        "Your limitation—it's only your imagination.",
        "Great things never come from comfort zones.",
        "Dream it. Wish it. Do it.",
        "Success doesn't just find you. You have to go out and get it.",
        "The harder you work for something, the greater you'll feel when you achieve it.",
        "Dream bigger. Do bigger.",
        "Don't stop when you're tired. Stop when you're done.",
        "Wake up with determination. Go to bed with satisfaction.",
        "Do something today that your future self will thank you for.",
        "Little things with great love.",
        "Don't wait for opportunity. Create it.",
        "Sometimes we're tested not to show our weaknesses, but to discover our strengths.",
        "The key to success is to focus on goals, not obstacles.",
        "Dream it. Believe it. Build it.",
        "What lies behind us and what lies before us are tiny matters compared to what lies within us."
    ]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Your Inspiration")
                            .font(.appSecondary)
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Select a quote that speaks to your soul")
                            .font(.appCaption)
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Quotes list
                    LazyVStack(spacing: 12) {
                        ForEach(inspirationalQuotes, id: \.self) { quote in
                            QuoteCardView(
                                quote: quote,
                                isSelected: selectedQuote == quote,
                                onTap: {
                                    selectedQuote = quote
                                    // Haptic feedback
                                    HapticFeedbackService.shared.provideFeedback(.selection)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Quote") {
                        if let quote = selectedQuote {
                            onQuoteSelected(quote)
                            dismiss()
                        }
                    }
                    .foregroundColor(theme.accent)
                    .disabled(selectedQuote == nil)
                }
            }
        }
    }
}

// MARK: - Quote Card View

struct QuoteCardView: View {
    let quote: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.accent)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(theme.accent)
                }
            }
            
            Text(quote)
                .font(.appBody)
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? theme.accent : theme.shadow.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview {
    ThemeSelectorView(
        onThemeSelected: { _ in },
        onQuoteSelected: {}
    )
}
