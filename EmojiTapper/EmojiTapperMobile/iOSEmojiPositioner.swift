//
//  iOSEmojiPositioner.swift
//  EmojiTapperMobile
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation
import SwiftUI

class iOSEmojiPositioner: EmojiPositioner {
    func generateRandomPosition(avoiding existingPositions: [CGPoint]) -> CGPoint {
        var attempts = 0
        let maxAttempts = 50
        
        while attempts < maxAttempts {
            let position = CGPoint(
                x: Double.random(in: 50...350),  // Wider range for iPhone
                y: Double.random(in: 100...700)  // Taller range for iPhone
            )
            
            // Check if this position overlaps with existing emojis
            let tooClose = existingPositions.contains { existingPosition in
                let distance = sqrt(pow(position.x - existingPosition.x, 2) + pow(position.y - existingPosition.y, 2))
                return distance < 50 // Slightly larger minimum distance for iPhone
            }
            
            if !tooClose {
                return position
            }
            
            attempts += 1
        }
        
        // If we can't find a non-overlapping position after max attempts, return a random one
        return CGPoint(
            x: Double.random(in: 50...350),
            y: Double.random(in: 100...700)
        )
    }
    
    func getTopmostEmojiAt(point: CGPoint, in emojis: [PositionedGameEmoji]) -> PositionedGameEmoji? {
        // Find emojis that contain this point (within 25 pixel radius for easier tapping on iPhone)
        let hitEmojis = emojis.filter { emoji in
            let distance = sqrt(pow(point.x - emoji.position.x, 2) + pow(point.y - emoji.position.y, 2))
            return distance <= 25 // Larger hit radius for iPhone
        }
        
        // Return the one with highest zIndex (rendered on top)
        return hitEmojis.max(by: { $0.zIndex < $1.zIndex })
    }
}