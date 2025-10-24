//
//  FontTestView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct FontTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Font Test")
                    .font(.appLogo)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Logo Font (Fraunces)")
                            .font(.appLogo)
                            .foregroundColor(.primary)
                        
                        Text("Onboarding Quote (Playfair)")
                            .font(.appOnboardingQuote)
                            .foregroundColor(.primary)
                        
                        Text("Secondary Text (Inter Light)")
                            .font(.appSecondary)
                            .foregroundColor(.primary)
                        
                        Text("Body Text (Nunito Sans)")
                            .font(.appBody)
                            .foregroundColor(.primary)
                        
                        Text("Button Text (Inter Medium)")
                            .font(.appButton)
                            .foregroundColor(.primary)
                        
                        Text("Caption Text (Nunito Sans)")
                            .font(.appCaption)
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    // Debug section - show system fonts for comparison
                    Text("System Fonts for Comparison:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("System Title")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                    Text("System Body")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("System Caption")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding()
                
                Button("Test Button") {
                    print("Button tapped")
                }
                .font(.appButton)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Font Test")
    }
}

#Preview {
    NavigationView {
        FontTestView()
    }
}
