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
    

    
    private var gameTimer: Timer?
    
    let normalEmojis = ["😀", "😊", "😂", "🥰", "😎", "🤔", "😮", "😋", "🙂", "😆", "😍", "🤗", "😴", "🤯", "😇"]
    let specialEmojis = ["💀", "⏳", "🍒"] // skull, hourglass, cherry
    
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
        }
        
        generateNewEmojis()
    }
    
    private func generateNewEmojis() {
        currentEmojis.removeAll()
        let targetCount = maxEmojisOnScreen
        
        var zIndex = 0
        
        // Add normal emojis (majority)
        let normalCount = max(1, targetCount - 3) // Leave room for 3 special emojis
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
        
        // Add special emojis (skull, hourglass, and cherry)
        for _ in 0..<3 {
            let specialEmoji = specialEmojis.randomElement() ?? "💀"
            let specialType: EmojiType = {
                switch specialEmoji {
                case "💀": return .skull
                case "⏳": return .hourglass
                case "🍒": return .cherry
                default: return .skull
                }
            }()
            
            let position = generateRandomPosition()
            currentEmojis.append(GameEmoji(
                emoji: specialEmoji,
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