//
//  PlatformGameState.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif

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
    var animatingEmojis: [AnimatedEmoji] = []
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
        setupEngineCallback()
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
        setupEngineCallback()
        currentEmojis.removeAll()
        animatingEmojis.removeAll()
    }
    
    private func setupEngineCallback() {
        gameEngine.onEmojisChanged = { [weak self] in
            DispatchQueue.main.async {
                if self?.gameEngine.gameMode == .penguinBall {
                    self?.syncWithEngine()
                } else {
                    self?.updatePositions()
                }
            }
        }
    }
    
    private func syncWithEngine() {
        // For Penguin Ball, animate emojis that are no longer in the engine
        let engineEmojiIDs = Set(gameEngine.currentEmojis.map { $0.id })
        let emojisToRemove = currentEmojis.filter { !engineEmojiIDs.contains($0.id) }
        
        // Start animations for removed emojis
        let screenBounds = getScreenBounds()
        for removedEmoji in emojisToRemove {
            let animatedEmoji = AnimatedEmoji(from: removedEmoji, screenBounds: screenBounds)
            animatingEmojis.append(animatedEmoji)
            
            // Remove the animated emoji after its animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + animatedEmoji.duration + 0.1) {
                self.animatingEmojis.removeAll { $0.id == animatedEmoji.id }
            }
        }
        
        // Remove emojis from current display (they're now animating)
        currentEmojis.removeAll { positionedEmoji in
            !engineEmojiIDs.contains(positionedEmoji.id)
        }
        
        // Add any new emojis that aren't positioned yet
        let positionedEmojiIDs = Set(currentEmojis.map { $0.id })
        for gameEmoji in gameEngine.currentEmojis {
            if !positionedEmojiIDs.contains(gameEmoji.id) {
                let existingPositions = currentEmojis.map { $0.position }
                let position = positioner.generateRandomPosition(avoiding: existingPositions)
                let positionedEmoji = PositionedGameEmoji(from: gameEmoji, position: position)
                currentEmojis.append(positionedEmoji)
            }
        }
    }
    
    private func getScreenBounds() -> CGRect {
        #if canImport(UIKit)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.bounds
        } else {
            return UIScreen.main.bounds
        }
        #else
        // Fallback for non-UIKit environments
        return CGRect(x: 0, y: 0, width: 800, height: 600)
        #endif
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
        animatingEmojis.removeAll()
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