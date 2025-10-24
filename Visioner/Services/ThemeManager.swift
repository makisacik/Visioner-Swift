//
//  ThemeManager.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import Combine

// MARK: - Theme Protocol

protocol AppTheme {
    var primary: Color { get }        // Branding, main headers, important text
    var secondary: Color { get }      // Cards, supporting backgrounds
    var background: Color { get }     // Canvas background
    var accent: Color { get }         // Buttons, highlights, interactive elements
    var accentStrong: Color { get }   // CTAs, toggles, progress bars
    var textPrimary: Color { get }    // Main text
    var textSecondary: Color { get }  // Supporting text
    var shadow: Color { get }         // Shadows and subtle outlines
}

// MARK: - Lavender Dreams Theme

struct LavenderDreamsTheme: AppTheme {
    var primary: Color        { Color(hex: "#7C64B2") } // main branding
    var secondary: Color      { Color(hex: "#C4B1E6") } // supporting UI
    var background: Color     { Color(hex: "#F4EFFC") } // canvas
    var accent: Color         { Color(hex: "#E9A8D0") } // CTA / highlights
    var accentStrong: Color   { Color(hex: "#4A3A6B") } // toggles / contrast

    var textPrimary: Color    { Color(hex: "#2B1F4A") } // dark text for readability
    var textSecondary: Color  { Color(hex: "#4A3A6B") } // softer text
    var shadow: Color         { Color(hex: "#C4B1E6").opacity(0.3) }
}

// MARK: - Theme Manager

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var currentTheme: AppTheme

    private init() {
        // Default theme
        self.currentTheme = LavenderDreamsTheme()
    }

    func apply(theme: AppTheme) {
        self.currentTheme = theme
    }
}

// MARK: - View Extension for Easier Access

extension View {
    var theme: AppTheme { ThemeManager.shared.currentTheme }
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16), (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24), (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
