//
//  FontLoader.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import CoreText

class FontLoader {
    static let shared = FontLoader()
    
    private init() {
        loadFonts()
    }
    
    private func loadFonts() {
        let fontNames = [
            "Fraunces_72pt_Soft-SemiBold.ttf",
            "PlayfairDisplay-Regular.ttf", 
            "Inter_28pt-Light.ttf",
            "Inter_28pt-Medium.ttf",
            "NunitoSans-VariableFont_YTLC,opsz,wdth,wght.ttf"
        ]
        
        for fontName in fontNames {
            if let fontURL = Bundle.main.url(forResource: fontName.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf") {
                if let fontData = NSData(contentsOf: fontURL) {
                    let provider = CGDataProvider(data: fontData)
                    if let font = CGFont(provider!) {
                        var error: Unmanaged<CFError>?
                        if !CTFontManagerRegisterGraphicsFont(font, &error) {
                            if let error = error {
                                let errorDescription = CFErrorCopyDescription(error.takeUnretainedValue())
                                print("Failed to register font \(fontName): \(errorDescription ?? "Unknown error" as CFString)")
                            }
                        } else {
                            print("Successfully registered font: \(fontName)")
                        }
                    }
                } else {
                    print("Could not load font data for: \(fontName)")
                }
            } else {
                print("Could not find font file: \(fontName)")
            }
        }
    }
    
    func getAvailableFonts() -> [String] {
        let fontFamilies = UIFont.familyNames.sorted()
        var allFonts: [String] = []
        
        for family in fontFamilies {
            let fonts = UIFont.fontNames(forFamilyName: family)
            for font in fonts {
                allFonts.append(font)
            }
        }
        
        return allFonts.sorted()
    }
}
