//
//  PlatformGameState.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation

// Platform-specific emoji with position
struct PositionedGameEmoji: Identifiable {
    let id: UUID
    let emoji: String
    let type: EmojiType
    let position: CGPoint
    let zIndex: Int
    
    init(from gameEmoji: GameEmoji, position: CGPoint) {
        self.id = gameEmoji.id  // Use the same ID from gameEmoji
        self.emoji = gameEmoji.emoji
        self.type = gameEmoji.type
        self.position = position
        self.zIndex = gameEmoji.zIndex
    }
}

// Platform-agnostic positioning protocol
protocol EmojiPositioner {
    func generateRandomPosition(avoiding existingPositions: [CGPoint]) -> CGPoint
    func getTopmostEmojiAt(point: CGPoint, in emojis: [PositionedGameEmoji]) -> PositionedGameEmoji?
}

@Observable
class PlatformGameState {
    private var gameEngine: GameModeEngine
    private let positioner: EmojiPositioner
    
    var currentEmojis: [PositionedGameEmoji] = []
    var selectedGameMode: GameMode = .classic {
        didSet {
            switchGameMode(to: selectedGameMode)
        }
    }
    
    // Forward properties from GameEngine
    var score: Int { gameEngine.score }
    var isGameActive: Bool { gameEngine.isGameActive }
    var highScore: Int { gameEngine.highScore }
    var gameStateText: String { gameEngine.gameStateText }
    
    // Classic mode specific properties for progress bar
    var timeRemainingForProgress: TimeInterval {
        if let classicEngine = gameEngine as? ClassicGameEngine {
            return classicEngine.timeRemainingForProgress
        }
        return 0
    }
    
    var totalTimeForProgress: TimeInterval {
        if let classicEngine = gameEngine as? ClassicGameEngine {
            return classicEngine.totalTimeForProgress
        }
        return 1
    }
    
    init(positioner: EmojiPositioner, gameMode: GameMode = .classic) {
        self.positioner = positioner
        self.selectedGameMode = gameMode
        self.gameEngine = Self.createEngine(for: gameMode)
    }
    
    private static func createEngine(for mode: GameMode) -> GameModeEngine {
        switch mode {
        case .classic:
            return ClassicGameEngine()
        case .penguinBall:
            return PenguinBallEngine()
        }
    }
    
    private func switchGameMode(to mode: GameMode) {
        if isGameActive {
            gameEngine.endGame()
        }
        gameEngine = Self.createEngine(for: mode)
        currentEmojis.removeAll()
    }
    
    func startGame() {
        gameEngine.startGame()
        // Force update positions after game engine generates emojis
        DispatchQueue.main.async {
            self.updatePositions()
        }
    }
    
    func endGame() {
        gameEngine.endGame()
        currentEmojis.removeAll()
    }
    
    func emojiTapped(_ emoji: PositionedGameEmoji) {
        // Find the corresponding GameEmoji by ID
        if let gameEmoji = gameEngine.currentEmojis.first(where: { $0.id == emoji.id }) {
            gameEngine.emojiTapped(gameEmoji)
            // Update positions after the engine processes the tap
            DispatchQueue.main.async {
                self.updatePositions()
            }
        }
    }
    
    func getTopmostEmojiAt(point: CGPoint) -> PositionedGameEmoji? {
        return positioner.getTopmostEmojiAt(point: point, in: currentEmojis)
    }
    
    private func updatePositions() {
        var existingPositions: [CGPoint] = []
        currentEmojis.removeAll()
        
        for gameEmoji in gameEngine.currentEmojis {
            let position = positioner.generateRandomPosition(avoiding: existingPositions)
            existingPositions.append(position)
            
            let positionedEmoji = PositionedGameEmoji(from: gameEmoji, position: position)
            currentEmojis.append(positionedEmoji)
        }
    }
}