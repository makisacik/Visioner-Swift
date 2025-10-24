//
//  HeartShapeDetector.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import Foundation
import SwiftUI

struct HeartShapeDetector {
    
    /// Analyzes a drawing path to determine if it forms a valid heart-like shape
    /// - Parameter points: Array of CGPoints representing the drawn path
    /// - Returns: Boolean indicating if the shape is a valid heart
    static func isHeartShape(points: [CGPoint]) -> Bool {
        guard points.count > 20 else { return false } // Minimum stroke length
        
        // Check basic requirements
        guard isClosedShape(points: points) else { return false }
        guard hasReasonableSize(points: points) else { return false }
        
        // Check for heart-like characteristics
        return hasHeartCharacteristics(points: points)
    }
    
    /// Checks if the drawing forms a closed shape
    private static func isClosedShape(points: [CGPoint]) -> Bool {
        guard let firstPoint = points.first, let lastPoint = points.last else { return false }
        
        let distance = sqrt(pow(lastPoint.x - firstPoint.x, 2) + pow(lastPoint.y - firstPoint.y, 2))
        return distance < 60 // Increased tolerance to 60 points
    }
    
    /// Checks if the drawing has a reasonable size for a heart
    private static func hasReasonableSize(points: [CGPoint]) -> Bool {
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 0
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 0
        
        let width = maxX - minX
        let height = maxY - minY
        let minSize: CGFloat = 60 // Reduced minimum size for a valid heart
        
        return width > minSize && height > minSize
    }
    
    /// Analyzes the shape for heart-like characteristics
    private static func hasHeartCharacteristics(points: [CGPoint]) -> Bool {
        let boundingBox = calculateBoundingBox(points: points)
        let centerX = (boundingBox.minX + boundingBox.maxX) / 2
        let centerY = (boundingBox.minY + boundingBox.maxY) / 2
        
        // Check if the shape has two upper lobes (characteristic of hearts)
        let upperPoints = points.filter { $0.y < centerY }
        let lowerPoints = points.filter { $0.y >= centerY }
        
        // Heart should have some points in upper and lower regions
        guard upperPoints.count > 5 && lowerPoints.count > 5 else { return false }
        
        // Check for asymmetry in upper region (two lobes)
        let leftUpperPoints = upperPoints.filter { $0.x < centerX }
        let rightUpperPoints = upperPoints.filter { $0.x >= centerX }
        
        // Should have points on both sides in upper region
        let hasTwoLobes = leftUpperPoints.count > 2 && rightUpperPoints.count > 2
        
        // Check for point at bottom (heart tip)
        let bottomPoints = points.filter { $0.y > centerY + (boundingBox.maxY - boundingBox.minY) * 0.6 }
        let hasHeartTip = bottomPoints.count > 3
        
        return hasTwoLobes && hasHeartTip
    }
    
    /// Calculates the bounding box of the drawn points
    private static func calculateBoundingBox(points: [CGPoint]) -> CGRect {
        guard !points.isEmpty else { return .zero }
        
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 0
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 0
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    /// Simplified version that just checks for closed shape with reasonable size
    /// This is used as a fallback for more lenient heart detection
    static func isBasicHeartShape(points: [CGPoint]) -> Bool {
        guard points.count > 15 else { return false } // Reduced minimum points
        
        let isClosed = isClosedShape(points: points)
        let hasSize = hasReasonableSize(points: points)
        
        return isClosed && hasSize
    }
}
