//
//  DrawingCanvasView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

struct DrawingCanvasView: View {
    @Binding var path: Path
    @Binding var isDrawing: Bool
    @Binding var hasValidDrawing: Bool
    let onDrawingComplete: () -> Void
    let onHeartDetected: () -> Void
    
    @State private var currentStroke: Path = Path()
    @State private var strokePoints: [CGPoint] = []
    @State private var lastPoint: CGPoint = .zero
    
    var body: some View {
        ZStack {
            // Canvas background
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .frame(width: 280, height: 280)
            
            // Drawing area
            Canvas { context, size in
                // Draw the completed path
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color(hex: "#E9A8D0").opacity(0.8)
                        ]),
                        startPoint: CGPoint(x: 0, y: size.height / 2),
                        endPoint: CGPoint(x: size.width, y: size.height / 2)
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                )
                
                // Draw outer glow effect
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(hex: "#E9A8D0").opacity(0.3),
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: CGPoint(x: 0, y: size.height / 2),
                        endPoint: CGPoint(x: size.width, y: size.height / 2)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
            }
            .frame(width: 280, height: 280)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDrawing {
                            // Start drawing
                            isDrawing = true
                            strokePoints.removeAll()
                            currentStroke = Path()
                            
                            // Haptic feedback on start
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                        
                        let currentPoint = value.location
                        
                        if strokePoints.isEmpty {
                            // First point
                            currentStroke.move(to: currentPoint)
                            path.move(to: currentPoint)
                            lastPoint = currentPoint
                        } else {
                            // Continue path
                            currentStroke.addLine(to: currentPoint)
                            path.addLine(to: currentPoint)
                            lastPoint = currentPoint
                        }
                        
                        strokePoints.append(currentPoint)
                    }
                    .onEnded { _ in
                        isDrawing = false
                        onDrawingComplete()
                        
                        // Check if drawing forms a valid heart-like shape
                        if HeartShapeDetector.isBasicHeartShape(points: strokePoints) {
                            hasValidDrawing = true
                            onHeartDetected()
                            
                            // Success haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                    }
            )
        }
    }
    
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "#7C64B2"),
                Color(hex: "#E9A8D0")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        DrawingCanvasView(
            path: .constant(Path()),
            isDrawing: .constant(false),
            hasValidDrawing: .constant(false),
            onDrawingComplete: {},
            onHeartDetected: {}
        )
    }
}
