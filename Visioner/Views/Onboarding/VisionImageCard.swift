//
//  VisionImageCard.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct VisionImageCard: View {
    let imageId: String
    let dream: ChooseYourVisionsViewModel.DreamCategory
    @ObservedObject var viewModel: ChooseYourVisionsViewModel
    
    var isSelected: Bool {
        viewModel.isImageSelected(imageId, for: dream)
    }
    
    var body: some View {
        ZStack {
            Image(imageId)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? 
                                AnyShapeStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#E9A8D0"),
                                            Color(hex: "#C4B1E6"),
                                            Color.white.opacity(0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                ) : AnyShapeStyle(Color.clear),
                            lineWidth: 3
                        )
                        .shadow(
                            color: isSelected ? Color.white.opacity(0.6) : .clear,
                            radius: 6
                        )
                )
                .overlay(
                    // ✨ Glowing checkmark overlay
                    VStack {
                        HStack {
                            Spacer()
                            if isSelected {
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color.white.opacity(0.4),
                                                    Color(hex: "#E9A8D0").opacity(0.6),
                                                    Color(hex: "#C4B1E6").opacity(0.6)
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 22
                                            )
                                        )
                                        .frame(width: 30, height: 30)
                                        .shadow(color: .white.opacity(0.8), radius: 4)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        Spacer()
                    }
                )
                .scaleEffect(isSelected ? 1.05 : 1.0) // 💫 soft enlargement
                .animation(.spring(response: 0.45, dampingFraction: 0.65), value: isSelected)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.selectImage(imageId, for: dream)
                    }
                }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "#4A3A6B"),
                Color(hex: "#7C64B2"),
                Color(hex: "#F4EFFC")
            ],
            startPoint: .bottom,
            endPoint: .top
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VisionImageCard(
                    imageId: "placeholder-1",
                    dream: .love,
                    viewModel: ChooseYourVisionsViewModel(selectedDreams: [.love])
                )
                
                VisionImageCard(
                    imageId: "placeholder-2",
                    dream: .love,
                    viewModel: ChooseYourVisionsViewModel(selectedDreams: [.love])
                )
            }
            
            Text("Tap to select images")
                .font(.appCaption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
    }
}
