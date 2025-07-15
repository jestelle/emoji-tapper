//
//  GameState.swift
//  EmojiTapper Watch App
//
//  Created by Josh Estelle on 7/15/25.
//

import SwiftUI
import Foundation

@Observable
class GameState {
    var score: Int = 0
    var timeRemaining: TimeInterval = 10.0
    var isGameActive: Bool = false
    var currentEmoji: String = "🎯"
    var emojiPosition: CGPoint = CGPoint(x: 75, y: 75)
    var currentLevel: GameLevel = BasicLevel()
    
    private var gameTimer: Timer?
    
    let availableEmojis = ["😀", "🎯", "⭐", "🎈", "🔥", "💎", "🎮", "⚡", "🌟", "🎊"]
    
    func startGame() {
        score = 0
        timeRemaining = currentLevel.initialTime
        isGameActive = true
        generateNewEmoji()
        startTimer()
    }
    
    func endGame() {
        isGameActive = false
        stopTimer()
    }
    
    func emojiTapped() {
        guard isGameActive else { return }
        
        let points = currentLevel.pointsForTapping(currentEmoji)
        score += points
        
        if points > 0 {
            timeRemaining += timeRemaining * currentLevel.timeBonus
        }
        
        generateNewEmoji()
    }
    
    private func generateNewEmoji() {
        currentEmoji = availableEmojis.randomElement() ?? "🎯"
        emojiPosition = CGPoint(
            x: Double.random(in: 30...120),
            y: Double.random(in: 30...120)
        )
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
}