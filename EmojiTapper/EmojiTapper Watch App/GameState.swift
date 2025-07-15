//
//  GameState.swift
//  EmojiTapper Watch App
//
//  Created by Josh Estelle on 7/15/25.
//

import SwiftUI
import Foundation

enum EmojiType {
    case normal
    case skull          // 💀 - ends game immediately  
    case hourglass      // ⏳ - adds 5 seconds
    case cherry         // 🍒 - gives 2 extra points
    case plus           // ➕ - makes emojis 10% bigger
    case minus          // ➖ - makes emojis 50% smaller
    case reset_size     // ⭕ - makes emojis normal size
    case hide           // 🥷 - makes all emojis 50% opacity
    case time_penalty_small // ❌ - reduces time by 5s
    case time_penalty_large // 💩 - reduces time by half
}

struct GameEmoji: Identifiable {
    let id = UUID()
    let emoji: String
    let type: EmojiType
    let position: CGPoint
    let zIndex: Int // Higher values render on top
}

@Observable
class GameState {
    var score: Int = 0
    var timeRemaining: TimeInterval = 10.0
    var isGameActive: Bool = false
    var currentEmojis: [GameEmoji] = []
    var currentLevel: GameLevel = BasicLevel()
    var highScore: Int = 0 {
        didSet {
            saveHighScore()
        }
    }
    
    // Visual state effects
    var emojiSizeMultiplier: Double = 1.0
    var emojiOpacity: Double = 1.0
    
    private var gameTimer: Timer?
    
    let normalEmojis = ["😀", "😊", "😂", "🥰", "😎", "🤔", "😮", "😋", "🙂", "😆", "😍", "🤗", "😴", "🤯", "😇"]
    let positiveEmojis = ["⏳", "🍒"] // hourglass, cherry
    let negativeEmojis = ["💀", "➕", "➖", "⭕", "🥷", "❌", "💩"] // skull, plus, minus, reset, hide, time penalties
    
    init() {
        loadHighScore()
    }
    
    private var maxEmojisOnScreen: Int {
        let elapsed = currentLevel.initialTime - timeRemaining
        // Start with 1 emoji, add 1 more every 2 seconds, max of 50
        return min(50, 1 + Int(elapsed / 2.0))
    }
    
    func startGame() {
        score = 0
        timeRemaining = currentLevel.initialTime
        isGameActive = true
        emojiSizeMultiplier = 1.0
        emojiOpacity = 1.0
        generateNewEmojis()
        startTimer()
    }
    
    func endGame() {
        isGameActive = false
        stopTimer()
        
        if score > highScore {
            highScore = score
        }
    }
    
    func emojiTapped(_ emoji: GameEmoji) {
        guard isGameActive else { return }
        
        switch emoji.type {
        case .normal:
            let points = currentLevel.pointsForTapping(emoji.emoji)
            score += points
            if points > 0 {
                timeRemaining += timeRemaining * currentLevel.timeBonus
            }
        case .skull:
            endGame()
            return
        case .hourglass:
            timeRemaining += 5.0
        case .cherry:
            score += 2
        case .plus:
            emojiSizeMultiplier = min(3.0, emojiSizeMultiplier * 1.1) // 10% bigger, cap at 3x
        case .minus:
            emojiSizeMultiplier = max(0.1, emojiSizeMultiplier * 0.5) // 50% smaller, min 0.1x
        case .reset_size:
            emojiSizeMultiplier = 1.0 // Reset to normal size
        case .hide:
            emojiOpacity = 0.5 // Make all emojis 50% opacity
        case .time_penalty_small:
            timeRemaining = max(0, timeRemaining - 5.0) // Reduce time by 5s
            if timeRemaining <= 0 {
                endGame()
                return
            }
        case .time_penalty_large:
            timeRemaining = max(0, timeRemaining / 2.0) // Reduce time by half
            if timeRemaining <= 0 {
                endGame()
                return
            }
        }
        
        generateNewEmojis()
    }
    
    private func generateNewEmojis() {
        currentEmojis.removeAll()
        let targetCount = maxEmojisOnScreen
        
        // Normal emojis: minimum 1, maximum 10% of total
        let normalCount = max(1, min(targetCount / 10, targetCount))
        
        // Negative emojis: fill most of the remaining space (90% of total)
        let negativeCount = targetCount - normalCount
        
        var zIndex = 0
        
        // Add normal emojis (only 10% or less)
        for _ in 0..<normalCount {
            let normalEmoji = normalEmojis.randomElement() ?? "😀"
            let position = generateRandomPosition()
            currentEmojis.append(GameEmoji(
                emoji: normalEmoji,
                type: .normal,
                position: position,
                zIndex: zIndex
            ))
            zIndex += 1
        }
        
        // Add negative emojis (90% of total)
        for _ in 0..<negativeCount {
            let negativeEmoji = negativeEmojis.randomElement() ?? "💀"
            let specialType: EmojiType = {
                switch negativeEmoji {
                case "💀": return .skull
                case "➕": return .plus
                case "➖": return .minus
                case "⭕": return .reset_size
                case "🥷": return .hide
                case "❌": return .time_penalty_small
                case "💩": return .time_penalty_large
                default: return .skull
                }
            }()
            
            let position = generateRandomPosition()
            currentEmojis.append(GameEmoji(
                emoji: negativeEmoji,
                type: specialType,
                position: position,
                zIndex: zIndex
            ))
            zIndex += 1
        }
    }
    
    private func generateRandomPosition() -> CGPoint {
        var attempts = 0
        let maxAttempts = 50
        
        while attempts < maxAttempts {
            let position = CGPoint(
                x: Double.random(in: 20...130),
                y: Double.random(in: 40...130)
            )
            
            // Check if this position overlaps with existing emojis
            let tooClose = currentEmojis.contains { existingEmoji in
                let distance = sqrt(pow(position.x - existingEmoji.position.x, 2) + pow(position.y - existingEmoji.position.y, 2))
                return distance < 35 // Minimum distance between emojis
            }
            
            if !tooClose {
                return position
            }
            
            attempts += 1
        }
        
        // If we can't find a non-overlapping position after max attempts, return a random one
        return CGPoint(
            x: Double.random(in: 20...130),
            y: Double.random(in: 40...130)
        )
    }
    
    func getTopmostEmojiAt(point: CGPoint) -> GameEmoji? {
        // Find emojis that contain this point (within 15 pixel radius)
        let hitEmojis = currentEmojis.filter { emoji in
            let distance = sqrt(pow(point.x - emoji.position.x, 2) + pow(point.y - emoji.position.y, 2))
            return distance <= 15 // Hit radius
        }
        
        // Return the one with highest zIndex (rendered on top)
        return hitEmojis.max(by: { $0.zIndex < $1.zIndex })
    }
    
    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "EmojiTapperHighScore")
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "EmojiTapperHighScore")
    }
}