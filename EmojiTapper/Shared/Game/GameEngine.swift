//
//  GameEngine.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation

@Observable
class GameEngine {
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
    
        let normalEmojis = [GameEmoji(emoji: "😀", type: .normal, zIndex: 0), GameEmoji(emoji: "😊", type: .normal, zIndex: 0), GameEmoji(emoji: "😂", type: .normal, zIndex: 0), GameEmoji(emoji: "🥰", type: .normal, zIndex: 0), GameEmoji(emoji: "😎", type: .normal, zIndex: 0), GameEmoji(emoji: "🤔", type: .normal, zIndex: 0), GameEmoji(emoji: "😮", type: .normal, zIndex: 0), GameEmoji(emoji: "😋", type: .normal, zIndex: 0), GameEmoji(emoji: "🙂", type: .normal, zIndex: 0), GameEmoji(emoji: "😆", type: .normal, zIndex: 0), GameEmoji(emoji: "😍", type: .normal, zIndex: 0), GameEmoji(emoji: "🤗", type: .normal, zIndex: 0), GameEmoji(emoji: "😴", type: .normal, zIndex: 0), GameEmoji(emoji: "🤯", type: .normal, zIndex: 0), GameEmoji(emoji: "😇", type: .normal, zIndex: 0)]
    let specialEmojis = [GameEmoji(emoji: "💀", type: .skull, zIndex: 0), GameEmoji(emoji: "⏳", type: .hourglass, zIndex: 0), GameEmoji(emoji: "🍒", type: .cherry, zIndex: 0)]
    
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
    
    func generateNewEmojis() {
        currentEmojis.removeAll()
        let targetCount = maxEmojisOnScreen
        
        
        
        // Always add at least one normal emoji
        currentEmojis.append(normalEmojis.randomElement()!)
        
        // Fill remaining slots with normal emojis
        let remainingSlots = targetCount - 1
        for _ in 0..<remainingSlots {
            // 40% chance for skull, 10% chance for hourglass (max 1), 10% chance for cherry (max 3)
            let randomValue = Double.random(in: 0...1)
            
            if randomValue < 0.4 {
                // Add skull (40% chance)
                currentEmojis.append(specialEmojis[0])
            } else if randomValue < 0.5 {
                // Check if we already have an hourglass
                let hasHourglass = currentEmojis.contains { $0.type == .hourglass }
                if !hasHourglass {
                    currentEmojis.append(specialEmojis[1])
                } else {
                    // Add normal emoji instead
                    let normalEmoji = normalEmojis.randomElement() ?? "😀"
                    currentEmojis.append(GameEmoji(
                        emoji: normalEmoji,
                        type: .normal,
                        zIndex: zIndex
                    ))
                    zIndex += 1
                }
            } else if randomValue < 0.6 {
                // Check if we already have 3 cherries
                let cherryCount = currentEmojis.filter { $0.type == .cherry }.count
                if cherryCount < 3 {
                    currentEmojis.append(GameEmoji(
                        emoji: "🍒",
                        type: .cherry,
                        zIndex: zIndex
                    ))
                    zIndex += 1
                } else {
                    // Add normal emoji instead
                    let normalEmoji = normalEmojis.randomElement() ?? "😀"
                    currentEmojis.append(GameEmoji(
                        emoji: normalEmoji,
                        type: .normal,
                        zIndex: zIndex
                    ))
                    zIndex += 1
                }
            } else {
                // Add normal emoji (40% chance)
                let normalEmoji = normalEmojis.randomElement() ?? "😀"
                currentEmojis.append(GameEmoji(
                    emoji: normalEmoji,
                    type: .normal,
                    zIndex: zIndex
                ))
                zIndex += 1
            }
        }
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
