//
//  AnimatedPositionChange.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation
import CoreGraphics

struct AnimatedPositionChange: Identifiable {
    let id: UUID
    let emoji: String
    let startPosition: CGPoint
    let endPosition: CGPoint
    let controlPoint1: CGPoint // For curved bezier path
    let controlPoint2: CGPoint // For curved bezier path
    let duration: TimeInterval
    
    init(from positionedEmoji: PositionedGameEmoji, to newPosition: CGPoint) {
        self.id = positionedEmoji.id
        self.emoji = positionedEmoji.emoji
        self.startPosition = positionedEmoji.position
        self.endPosition = newPosition
        self.duration = Double.random(in: 0.3...0.5)
        
        // Create curved path with random control points
        let deltaX = newPosition.x - positionedEmoji.position.x
        let deltaY = newPosition.y - positionedEmoji.position.y
        let midX = positionedEmoji.position.x + deltaX * 0.5
        let midY = positionedEmoji.position.y + deltaY * 0.5
        
        // Add some randomness to create interesting curved paths
        let curveIntensity: CGFloat = 50
        let angle1 = Double.random(in: 0...Double.pi * 2)
        let angle2 = angle1 + Double.pi // Opposite direction for second control point
        
        self.controlPoint1 = CGPoint(
            x: midX + cos(angle1) * curveIntensity,
            y: midY + sin(angle1) * curveIntensity
        )
        
        self.controlPoint2 = CGPoint(
            x: midX + cos(angle2) * curveIntensity,
            y: midY + sin(angle2) * curveIntensity
        )
    }
}
