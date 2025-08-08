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
    
    // Manual constructor for preserving exact properties
    init(id: UUID, emoji: String, type: EmojiType, position: CGPoint, zIndex: Int) {
        self.id = id
        self.emoji = emoji
        self.type = type
        self.position = position
        self.zIndex = zIndex
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
    var animatedPositionChanges: [AnimatedPositionChange] = []
    var celebratingPenguin: PositionedGameEmoji? = nil
    var showGameEndScreen: Bool = false
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
    
    // Penguin Ball specific properties
    var roundScores: [Int] {
        if let penguinEngine = gameEngine as? PenguinBallEngine {
            return penguinEngine.roundScores
        }
        return []
    }
    
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
        animatedPositionChanges.removeAll()
        celebratingPenguin = nil
        showGameEndScreen = false
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
        // Show end screen for Penguin Ball BEFORE ending the game
        // to prevent briefly showing the main menu
        if gameEngine.gameMode == .penguinBall {
            showGameEndScreen = true
        }
        
        gameEngine.endGame()
        currentEmojis.removeAll()
        animatingEmojis.removeAll()
        animatedPositionChanges.removeAll()
        celebratingPenguin = nil
    }
    
    func dismissGameEndScreen() {
        showGameEndScreen = false
    }
    
    func emojiTapped(_ emoji: PositionedGameEmoji) {
        // Find the corresponding GameEmoji by ID
        if let gameEmoji = gameEngine.currentEmojis.first(where: { $0.id == emoji.id }) {
            
            // Special handling for Penguin Ball penguin clicks
            if gameEngine.gameMode == .penguinBall && gameEmoji.emoji == "🐧" {
                handlePenguinCelebration(clickedPenguin: emoji)
            } else if gameEngine.gameMode == .penguinBall {
                // Wrong emoji in Penguin Ball - animate position changes
                handleWrongEmojiTap(gameEmoji)
            } else {
                gameEngine.emojiTapped(gameEmoji)
                // Update positions after the engine processes the tap
                DispatchQueue.main.async {
                    self.updatePositions()
                }
            }
        }
    }
    
    private func handleWrongEmojiTap(_ gameEmoji: GameEmoji) {
        gameEngine.emojiTapped(gameEmoji) // Process the tap (no penalty in Penguin Ball)
        
        // Pause disappearing timers during animation
        gameEngine.pauseTimers()
        
        // Generate new positions for all current emojis
        var newPositions: [UUID: CGPoint] = [:]
        var existingPositions: [CGPoint] = []
        
        for emoji in currentEmojis {
            let newPosition = positioner.generateRandomPosition(avoiding: existingPositions)
            newPositions[emoji.id] = newPosition
            existingPositions.append(newPosition)
        }
        
        // Create animated position changes for all emojis
        for emoji in currentEmojis {
            if let newPosition = newPositions[emoji.id] {
                let animatedChange = AnimatedPositionChange(from: emoji, to: newPosition)
                animatedPositionChanges.append(animatedChange)
            }
        }
        
        // Hide current emojis during animation
        let animatingEmojiIds = Set(animatedPositionChanges.map { $0.id })
        currentEmojis.removeAll { animatingEmojiIds.contains($0.id) }
        
        // After animations complete, set final positions and resume timers
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Max animation duration
            // Set final positions without regenerating them - use exact animation end positions
            self.currentEmojis = self.animatedPositionChanges.compactMap { change in
                // Find corresponding engine emoji to preserve type and other properties
                if let engineEmoji = self.gameEngine.currentEmojis.first(where: { $0.id == change.id }) {
                    // Create positioned emoji manually to preserve the exact ID and final position
                    return PositionedGameEmoji(
                        id: change.id, // Keep same ID
                        emoji: engineEmoji.emoji,
                        type: engineEmoji.type,
                        position: change.endPosition, // Use animation end position
                        zIndex: engineEmoji.zIndex
                    )
                }
                return nil
            }
            
            self.animatedPositionChanges.removeAll()
            // Resume disappearing timers after animation
            self.gameEngine.resumeTimers()
        }
    }
    
    private func handlePenguinCelebration(clickedPenguin: PositionedGameEmoji) {
        // Tap the penguin in the engine first (updates score, etc.)
        if let gameEmoji = gameEngine.currentEmojis.first(where: { $0.id == clickedPenguin.id }) {
            gameEngine.emojiTapped(gameEmoji)
        }
        
        // Check if game should end after this round (before celebration)
        let shouldEndGame = if let penguinEngine = gameEngine as? PenguinBallEngine {
            penguinEngine.roundScores.count >= 5 // All 5 rounds complete
        } else {
            false
        }
        
        if shouldEndGame {
            // Show end screen immediately for final round
            showGameEndScreen = true
            gameEngine.endGame()
            currentEmojis.removeAll()
            animatingEmojis.removeAll()
            celebratingPenguin = nil
            return
        }
        
        // Start celebration: penguin grows, others animate away
        celebratingPenguin = clickedPenguin
        
        // Animate all non-penguin emojis away
        let nonPenguinEmojis = currentEmojis.filter { $0.id != clickedPenguin.id }
        let screenBounds = getScreenBounds()
        
        for emoji in nonPenguinEmojis {
            let animatedEmoji = AnimatedEmoji(from: emoji, screenBounds: screenBounds)
            animatingEmojis.append(animatedEmoji)
            
            // Clean up animated emoji after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + animatedEmoji.duration + 0.1) {
                self.animatingEmojis.removeAll { $0.id == animatedEmoji.id }
            }
        }
        
        // Remove non-penguin emojis from current display
        currentEmojis.removeAll { $0.id != clickedPenguin.id }
        
        // After celebration period, proceed to next round
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.celebratingPenguin = nil
            self.gameEngine.proceedToNextRound()
            self.updatePositions()
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