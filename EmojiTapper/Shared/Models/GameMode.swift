//
//  GameMode.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation

enum GameMode: String, CaseIterable {
    case classic = "Classic"
    case penguinBall = "Penguin Ball"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .classic:
            return "Tap emojis to score points and earn time"
        case .penguinBall:
            return "Find the penguin among many emojis in 5 rounds"
        }
    }
}

protocol GameModeEngine {
    var gameMode: GameMode { get }
    var score: Int { get }
    var isGameActive: Bool { get }
    var currentEmojis: [GameEmoji] { get }
    var gameStateText: String { get } // For displaying round info, time, etc.
    var highScore: Int { get }
    var onEmojisChanged: (() -> Void)? { get set } // Callback for UI updates
    var onGameEnded: (() -> Void)? { get set } // Callback when game ends
    
    func startGame()
    func endGame()
    func emojiTapped(_ emoji: GameEmoji)
    func proceedToNextRound() // For Penguin Ball round progression
    func pauseTimers() // Pause disappearing timers during animations
    func resumeTimers() // Resume timers after animations complete
    func resetHighScore() // Reset the high score for this game mode
}