//
//  GameLevel.swift
//  Shared
//
//  Created by Josh Estelle on 7/15/25.
//

import Foundation

protocol GameLevel {
    var name: String { get }
    var initialTime: TimeInterval { get }
    var timeBonus: Double { get } // Percentage bonus when emoji is tapped
    
    func shouldShowEmoji(_ emoji: String, in availableEmojis: [String]) -> Bool
    func pointsForTapping(_ emoji: String) -> Int
}

struct BasicLevel: GameLevel {
    let name = "Basic"
    let initialTime: TimeInterval = 30.0
    let timeBonus: Double = 0.0 // No time bonus
    
    func shouldShowEmoji(_ emoji: String, in availableEmojis: [String]) -> Bool {
        return true // Show any emoji
    }
    
    func pointsForTapping(_ emoji: String) -> Int {
        return 1 // One point per tap
    }
}

struct SelectiveLevel: GameLevel {
    let name = "Selective"
    let initialTime: TimeInterval = 15.0
    let timeBonus: Double = 0.15 // 15% time bonus
    let targetEmoji: String
    
    init(targetEmoji: String = "⭐") {
        self.targetEmoji = targetEmoji
    }
    
    func shouldShowEmoji(_ emoji: String, in availableEmojis: [String]) -> Bool {
        return true // Show all emojis, but only target gives points
    }
    
    func pointsForTapping(_ emoji: String) -> Int {
        return emoji == targetEmoji ? 2 : 0 // Points only for correct emoji
    }
}