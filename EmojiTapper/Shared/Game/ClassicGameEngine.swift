//
//  ClassicGameEngine.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation

@Observable
class ClassicGameEngine: GameModeEngine {
    let gameMode: GameMode = .classic
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
    
    var gameStateText: String {
        return String(format: "%.1f", timeRemaining)
    }
    
    // For progress bar in UI
    var timeRemainingForProgress: TimeInterval { timeRemaining }
    var totalTimeForProgress: TimeInterval { currentLevel.initialTime }
    var onEmojisChanged: (() -> Void)?
    var onGameEnded: (() -> Void)?
    
    private var gameTimer: Timer?
    
    private let skullEmoji = GameEmoji(emoji: "💀", type: .skull)
    private let hourglassEmoji = GameEmoji(emoji: "⏳", type: .hourglass)
    private let cherryEmoji = GameEmoji(emoji: "🍒", type: .cherry)
    
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
        
        // Notify that game has ended
        onGameEnded?()
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
            timeRemaining += 2.0
        case .cherry:
            score += 3
        }
        
        generateNewEmojis()
        onEmojisChanged?()
    }
    
    func proceedToNextRound() {
        // Classic mode doesn't have rounds, so this does nothing
    }
    
    func pauseTimers() {
        // Classic mode doesn't need timer pausing for position animations
    }
    
    func resumeTimers() {
        // Classic mode doesn't need timer resuming for position animations
    }
    
    func generateNewEmojis() {
        currentEmojis.removeAll()
        let targetCount = maxEmojisOnScreen
        
        // Always add at least one normal emoji
        if let (emoji, type) = EmojiProvider.classicNormal.randomElement() {
            currentEmojis.append(GameEmoji(emoji: emoji, type: type))
        }
        
        // Fill remaining slots
        let remainingSlots = targetCount - currentEmojis.count
        for _ in 0..<remainingSlots {
            let randomValue = Double.random(in: 0...1)
            
            if randomValue < 0.4 {
                // Add skull (40% chance)
                currentEmojis.append(skullEmoji)
            } else if randomValue < 0.5 {
                // Add hourglass (10% chance, max 1)
                if !currentEmojis.contains(where: { $0.type == .hourglass }) {
                    currentEmojis.append(hourglassEmoji)
                } else if let (emoji, type) = EmojiProvider.classicNormal.randomElement() {
                    currentEmojis.append(GameEmoji(emoji: emoji, type: type))
                }
            } else if randomValue < 0.6 {
                // Add cherry (10% chance, max 3)
                if currentEmojis.filter({ $0.type == .cherry }).count < 3 {
                    currentEmojis.append(cherryEmoji)
                } else if let (emoji, type) = EmojiProvider.classicNormal.randomElement() {
                    currentEmojis.append(GameEmoji(emoji: emoji, type: type))
                }
            } else {
                // Add normal emoji
                if let (emoji, type) = EmojiProvider.classicNormal.randomElement() {
                    currentEmojis.append(GameEmoji(emoji: emoji, type: type))
                }
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
        UserDefaults.standard.set(highScore, forKey: "EmojiTapperClassicHighScore")
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "EmojiTapperClassicHighScore")
    }
    
    func resetHighScore() {
        highScore = 0
        UserDefaults.standard.set(0, forKey: "EmojiTapperClassicHighScore")
    }
}
