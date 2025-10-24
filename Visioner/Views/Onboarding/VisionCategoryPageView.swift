//
//  VisionCategoryPageView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct VisionCategoryPageView: View {
    let dream: ChooseYourVisionsViewModel.DreamCategory
    @ObservedObject var viewModel: ChooseYourVisionsViewModel
    
    @State private var showHeader = false
    @State private var showGrid = false
    @State private var categoryGlow = false
    
    private let imageIds = ["placeholder-1", "placeholder-2", "placeholder-3", "placeholder-4", 
                           "placeholder-5", "placeholder-6", "placeholder-7", "placeholder-8"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Category Header
            HStack(spacing: 12) {
                Text(dream.rawValue)
                    .font(.system(size: 28))
                    .scaleEffect(showHeader ? 1.0 : 0.8)
                    .opacity(showHeader ? 1.0 : 0.0)
                
                Text(dream.title)
                    .font(.appBody)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .opacity(showHeader ? 1.0 : 0.0)
                    .overlay(
                        // Category-specific glow
                        Text(dream.title)
                            .font(.appBody)
                            .fontWeight(.medium)
                            .foregroundColor(dream.categoryColor)
                            .blur(radius: 4)
                            .opacity(categoryGlow ? 0.3 : 0.0)
                    )
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            
            // Image Grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 12) {
                    ForEach(imageIds, id: \.self) { imageId in
                        VisionImageCard(
                            imageId: imageId,
                            dream: dream,
                            viewModel: viewModel
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 450)
            .opacity(showGrid ? 1.0 : 0.0)
            
            // Selection Counter
            HStack {
                Text("\(viewModel.getSelectedCount(for: dream))/3 selected")
                    .font(.appCaption)
                    .foregroundColor(.white.opacity(0.6))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.getSelectedCount(for: dream))
                
                Spacer()
                
                if viewModel.getSelectedCount(for: dream) > 0 {
                    Text("✨")
                        .font(.system(size: 16))
                        .opacity(showGrid ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.getSelectedCount(for: dream))
                }
            }
            .padding(.horizontal, 32)
            .opacity(showGrid ? 1.0 : 0.0)
        }
        .onAppear {
            startPageAnimation()
        }
        .onChange(of: viewModel.getSelectedCount(for: dream)) { _ in
            // Pulse glow when selection changes
            withAnimation(.easeInOut(duration: 0.3)) {
                categoryGlow = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    categoryGlow = false
                }
            }
        }
    }
    
    private func startPageAnimation() {
        // Header fade in
        withAnimation(.easeInOut(duration: 0.8)) {
            showHeader = true
        }
        
        // Grid rise up
        withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
            showGrid = true
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
        
        VisionCategoryPageView(
            dream: .love,
            viewModel: ChooseYourVisionsViewModel(selectedDreams: [.love, .career])
        )
    }
}
