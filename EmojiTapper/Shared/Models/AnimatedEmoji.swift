//
//  AnimatedEmoji.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation

struct AnimatedEmoji: Identifiable {
    let id: UUID
    let emoji: String
    let startPosition: CGPoint
    let endPosition: CGPoint
    let duration: TimeInterval
    
    init(from positionedEmoji: PositionedGameEmoji, screenBounds: CGRect) {
        self.id = positionedEmoji.id
        self.emoji = positionedEmoji.emoji
        self.startPosition = positionedEmoji.position
        self.duration = Double.random(in: 0.8...1.5)
        
        // Calculate which screen edge is closest
        let x = positionedEmoji.position.x
        let y = positionedEmoji.position.y
        
        let distanceToLeft = x
        let distanceToRight = screenBounds.width - x
        let distanceToTop = y
        let distanceToBottom = screenBounds.height - y
        
        let minDistance = min(distanceToLeft, distanceToRight, distanceToTop, distanceToBottom)
        
        // Fly towards the closest edge with some randomness
        let overshoot: CGFloat = 100 // How far off screen to animate
        var endX: CGFloat
        var endY: CGFloat
        
        if minDistance == distanceToLeft {
            // Fly left
            endX = -overshoot
            endY = y + CGFloat.random(in: -50...50)
        } else if minDistance == distanceToRight {
            // Fly right
            endX = screenBounds.width + overshoot
            endY = y + CGFloat.random(in: -50...50)
        } else if minDistance == distanceToTop {
            // Fly up
            endX = x + CGFloat.random(in: -50...50)
            endY = -overshoot
        } else {
            // Fly down
            endX = x + CGFloat.random(in: -50...50)
            endY = screenBounds.height + overshoot
        }
        
        self.endPosition = CGPoint(x: endX, y: endY)
    }
}