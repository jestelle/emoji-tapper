//
//  WatchEmojiPositioner.swift
//  EmojiTapper Watch App
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation
import SwiftUI

class WatchEmojiPositioner: EmojiPositioner {
    func generateRandomPosition(avoiding existingPositions: [CGPoint]) -> CGPoint {
        var attempts = 0
        let maxAttempts = 50
        
        // Allow more overlap for Penguin Ball mode when there are many emojis
        let minDistance: Double = existingPositions.count > 30 ? 15 : 35
        
        while attempts < maxAttempts {
            let position = CGPoint(
                x: Double.random(in: 10...180),
                y: Double.random(in: 35...180)
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
            x: Double.random(in: 10...180),
            y: Double.random(in: 35...180)
        )
    }
    
    func getTopmostEmojiAt(point: CGPoint, in emojis: [PositionedGameEmoji]) -> PositionedGameEmoji? {
        // Find emojis that contain this point (within 15 pixel radius)
        let hitEmojis = emojis.filter { emoji in
            let distance = sqrt(pow(point.x - emoji.position.x, 2) + pow(point.y - emoji.position.y, 2))
            return distance <= 15 // Hit radius
        }
        
        // Return the one with highest zIndex (rendered on top)
        return hitEmojis.max(by: { $0.zIndex < $1.zIndex })
    }
}