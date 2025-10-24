//
//  FontDebugView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct FontDebugView: View {
    @State private var availableFonts: [String] = []
    @State private var fontTestResults: [String: Bool] = [:]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Font Debug Information")
                    .font(.title)
                    .padding()
                
                Text("Total Available Fonts: \(availableFonts.count)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Font test results
                VStack(alignment: .leading, spacing: 8) {
                    Text("Font Test Results:")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(Array(fontTestResults.keys.sorted()), id: \.self) { fontName in
                        HStack {
                            Text(fontName)
                                .font(.body)
                            Spacer()
                            Text(fontTestResults[fontName] == true ? "✅" : "❌")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                
                Text("Direct Font Tests:")
                    .font(.headline)
                    .padding()
                
                // Test each font directly
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        Text("Fraunces 72pt Soft SemiBold")
                            .font(.custom("Fraunces 72pt Soft SemiBold", size: 20))
                            .foregroundColor(.primary)
                        
                        Text("Playfair Display")
                            .font(.custom("Playfair Display", size: 20))
                            .foregroundColor(.primary)
                        
                        Text("Inter 28pt Light")
                            .font(.custom("Inter 28pt Light", size: 20))
                            .foregroundColor(.primary)
                        
                        Text("Inter 28pt Medium")
                            .font(.custom("Inter 28pt Medium", size: 20))
                            .foregroundColor(.primary)
                        
                        Text("Nunito Sans")
                            .font(.custom("Nunito Sans", size: 20))
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                
                Divider()
                
                Text("All Available Fonts (first 20):")
                    .font(.headline)
                    .padding()
                
                ForEach(Array(availableFonts.prefix(20)), id: \.self) { fontName in
                    Text(fontName)
                        .font(.custom(fontName, size: 14))
                        .padding(.horizontal)
                }
                
                Divider()
                
                Text("Bundle Font Files:")
                    .font(.headline)
                    .padding()
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(getBundleFontFiles(), id: \.self) { fileName in
                        Text("📁 \(fileName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadAvailableFonts()
            testCustomFonts()
        }
    }
    
    private func loadAvailableFonts() {
        availableFonts = FontLoader.shared.getAvailableFonts()
    }
    
    private func testCustomFonts() {
        let testFonts = [
            "Fraunces 72pt Soft SemiBold",
            "Playfair Display", 
            "Inter 28pt Light",
            "Inter 28pt Medium",
            "Nunito Sans"
        ]
        
        for fontName in testFonts {
            let font = UIFont(name: fontName, size: 16)
            fontTestResults[fontName] = (font != nil)
        }
    }
    
    private func getBundleFontFiles() -> [String] {
        var fontFiles: [String] = []
        
        if let bundlePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: bundlePath)
                fontFiles = contents.filter { $0.hasSuffix(".ttf") || $0.hasSuffix(".otf") }
            } catch {
                print("Error reading bundle contents: \(error)")
            }
        }
        
        return fontFiles.sorted()
    }
}

#Preview {
    NavigationView {
        FontDebugView()
    }
}
