//
//  DrawingImageService.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import UIKit

struct DrawingImageService {
    
    /// Converts a SwiftUI Path to UIImage and saves it to disk
    /// - Parameters:
    ///   - path: The SwiftUI Path to convert
    ///   - size: The size of the image to generate
    ///   - filename: Optional custom filename (defaults to timestamped name)
    /// - Returns: The file path where the image was saved, or nil if failed
    static func saveDrawingToDisk(path: Path, size: CGSize = CGSize(width: 280, height: 280), filename: String? = nil) -> String? {
        
        // Create the image from the path
        guard let image = createImageFromPath(path: path, size: size) else {
            print("Failed to create image from path")
            return nil
        }
        
        // Get documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory")
            return nil
        }
        
        // Create filename
        let fileName = filename ?? "heart_drawing_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Save image to disk
        guard let imageData = image.pngData() else {
            print("Failed to convert image to PNG data")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            print("Heart drawing saved to: \(fileURL.path)")
            
            // Store the file path in UserDefaults for later retrieval
            UserDefaults.standard.set(fileURL.path, forKey: "savedHeartDrawingPath")
            
            return fileURL.path
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    /// Creates a UIImage from a SwiftUI Path
    private static func createImageFromPath(path: Path, size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: DrawingPathView(path: path))
        renderer.proposedSize = .init(width: size.width, height: size.height)
        
        // Configure for high quality
        renderer.scale = UIScreen.main.scale
        
        return renderer.uiImage
    }
    
    /// Retrieves the saved heart drawing image
    /// - Returns: UIImage if found, nil otherwise
    static func getSavedHeartDrawing() -> UIImage? {
        guard let savedPath = UserDefaults.standard.string(forKey: "savedHeartDrawingPath") else {
            return nil
        }
        
        let fileURL = URL(fileURLWithPath: savedPath)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Saved heart drawing file not found at: \(fileURL.path)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            print("Failed to read image data from: \(fileURL.path)")
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    /// Checks if a heart drawing has been saved
    /// - Returns: Boolean indicating if a saved heart drawing exists
    static func hasSavedHeartDrawing() -> Bool {
        guard let savedPath = UserDefaults.standard.string(forKey: "savedHeartDrawingPath") else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: savedPath)
    }
    
    /// Removes the saved heart drawing
    static func removeSavedHeartDrawing() {
        guard let savedPath = UserDefaults.standard.string(forKey: "savedHeartDrawingPath") else {
            return
        }
        
        let fileURL = URL(fileURLWithPath: savedPath)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            UserDefaults.standard.removeObject(forKey: "savedHeartDrawingPath")
            print("Saved heart drawing removed")
        } catch {
            print("Failed to remove saved heart drawing: \(error)")
        }
    }
}

// MARK: - DrawingPathView for ImageRenderer

private struct DrawingPathView: View {
    let path: Path
    
    var body: some View {
        ZStack {
            // Transparent background
            Color.clear
            
            // The drawing path
            path
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color(hex: "#E9A8D0").opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                )
        }
        .frame(width: 280, height: 280)
    }
}
