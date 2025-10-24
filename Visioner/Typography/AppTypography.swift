//
//  AppTypography.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

enum AppFontName {
    static let frauncesSemiBold = "Fraunces 72pt Soft SemiBold"
    static let playfairRegular  = "Playfair Display"
    static let interLight       = "Inter 28pt Light"
    static let interMedium      = "Inter 28pt Medium"
    static let nunitoSans       = "Nunito Sans"   // variable family
}

enum AppFontSize {
    static let display: CGFloat  = 32   // logo / brand
    static let quote: CGFloat    = 30   // main onboarding quote
    static let secondary: CGFloat = 18  // subtitle under quote
    static let body: CGFloat     = 16   // body text
    static let button: CGFloat   = 16   // buttons
    static let caption: CGFloat  = 13
}

extension Font {
    // semantic styles
    static var appLogo: Font {
        .custom(AppFontName.frauncesSemiBold,
                size: AppFontSize.display,
                relativeTo: .largeTitle)
    }

    static var appOnboardingQuote: Font {
        .custom(AppFontName.playfairRegular,
                size: AppFontSize.quote,
                relativeTo: .title)
    }

    static var appSecondary: Font {
        .custom(AppFontName.interLight,
                size: AppFontSize.secondary,
                relativeTo: .title3)
    }

    static var appBody: Font {
        .custom(AppFontName.nunitoSans,
                size: AppFontSize.body,
                relativeTo: .body)
    }

    static var appButton: Font {
        .custom(AppFontName.interMedium,
                size: AppFontSize.button,
                relativeTo: .callout)
    }

    static var appCaption: Font {
        .custom(AppFontName.nunitoSans,
                size: AppFontSize.caption,
                relativeTo: .caption)
    }
}
