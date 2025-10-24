//
//  VisionBoardModels.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI

// MARK: - Codable Size and Rect
struct CodableSize: Codable {
    let width: CGFloat
    let height: CGFloat
    
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
    
    init(from cgSize: CGSize) {
        self.width = cgSize.width
        self.height = cgSize.height
    }
}

struct CodableRect: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
    
    init(from cgRect: CGRect) {
        self.x = cgRect.origin.x
        self.y = cgRect.origin.y
        self.width = cgRect.width
        self.height = cgRect.height
    }
}

// MARK: - Vision Board Template
struct VisionBoardTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let gridSize: CodableSize        // in grid units, not pixels (e.g. 12×8)
    let slots: [VisionSlotTemplate]
    let theme: VisionTheme?
    
    var cgGridSize: CGSize {
        gridSize.cgSize
    }
}

// MARK: - Slot Template (position + type)
struct VisionSlotTemplate: Identifiable, Codable {
    let id: Int
    let rect: CodableRect            // normalized 0–1 coordinates or grid cell rect
    let type: SlotType
    
    var cgRect: CGRect {
        rect.cgRect
    }
}

// MARK: - Slot Type
enum SlotType: String, Codable {
    case image
    case text
}

// MARK: - Vision Theme
struct VisionTheme: Codable {
    var backgroundColorHex: String
    var accentColorHex: String
    var fontName: String
}

// MARK: - User Board & Slot Content (for future use)
struct VisionBoard: Identifiable {
    let id: UUID
    let templateId: String
    var title: String
    var createdDate: Date
    var slots: [VisionSlotContent]
}

struct VisionSlotContent: Identifiable {
    let id: Int
    let type: SlotType
    var imageData: Data?
    var text: String?
    var style: VisionTextStyle?
}

// MARK: - Text Style (for future use)
struct VisionTextStyle {
    var fontName: String
    var fontSize: CGFloat
    var colorHex: String
    var alignment: TextAlignment
    var shadow: Bool
}

// MARK: - Extensions
extension VisionBoard {
    static func fromTemplate(_ template: VisionBoardTemplate, title: String) -> VisionBoard {
        VisionBoard(
            id: UUID(),
            templateId: template.id,
            title: title,
            createdDate: Date(),
            slots: template.slots.map { slot in
                VisionSlotContent(
                    id: slot.id,
                    type: slot.type,
                    imageData: nil,
                    text: slot.type == .text ? "Tap to edit" : nil,
                    style: nil
                )
            }
        )
    }
}
