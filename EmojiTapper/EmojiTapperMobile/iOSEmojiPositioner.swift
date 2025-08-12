//
//  iOSEmojiPositioner.swift
//  EmojiTapperMobile
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

class iOSEmojiPositioner: EmojiPositioner {
    func generateRandomPosition(avoiding existingPositions: [CGPoint]) -> CGPoint {
        var attempts = 0
        let maxAttempts = 50
        
        // Allow more overlap for Penguin Ball mode when there are many emojis
        let minDistance: Double = existingPositions.count > 50 ? 20 : 50
        
        // Get actual screen bounds dynamically
        let screenBounds = getScreenBounds()
        let margin: CGFloat = 30
        
        let minX = margin
        let maxX = screenBounds.width - margin
        let minY = margin + 100  // Account for status bar and game UI
        let maxY = screenBounds.height - margin - 100  // Account for home indicator and game UI
        
        while attempts < maxAttempts {
            let position = CGPoint(
                x: Double.random(in: minX...maxX),
                y: Double.random(in: minY...maxY)
            )
            
            // Check if this position overlaps with existing emojis
            let tooClose = existingPositions.contains { existingPosition in
                let distance = sqrt(pow(position.x - existingPosition.x, 2) + pow(position.y - existingPosition.y, 2))
                return distance < minDistance
            }
            
            if !tooClose {
                return position
            }
            
            attempts += 1
        }
        
        // If we can't find a non-overlapping position after max attempts, return a random one
        return CGPoint(
            x: Double.random(in: minX...maxX),
            y: Double.random(in: minY...maxY)
        )
    }
    
    private func getScreenBounds() -> CGRect {
        #if canImport(UIKit)
        // Get the main screen bounds
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.bounds
        } else {
            return UIScreen.main.bounds
        }
        #else
        // Fallback for non-UIKit environments
        return CGRect(x: 0, y: 0, width: 400, height: 800)
        #endif
    }
    
    func getTopmostEmojiAt(point: CGPoint, in emojis: [PositionedGameEmoji]) -> PositionedGameEmoji? {
        // Find emojis that contain this point (within 25 pixel radius for easier tapping on iPhone)
        let hitEmojis = emojis.filter { emoji in
            let distance = sqrt(pow(point.x - emoji.position.x, 2) + pow(point.y - emoji.position.y, 2))
            return distance <= 25 // Larger hit radius for iPhone
        }
        
        // Return the first one
        return hitEmojis.first
    }
}