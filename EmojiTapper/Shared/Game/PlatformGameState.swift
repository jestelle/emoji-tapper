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
#if os(watchOS)
import WatchKit
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
        
        gameEngine.onGameEnded = { [weak self] in
            DispatchQueue.main.async {
                // Just show the end screen - the engine has already ended
                self?.showGameEndScreen = true
                self?.currentEmojis.removeAll()
                self?.animatingEmojis.removeAll()
                self?.animatedPositionChanges.removeAll()
                self?.celebratingPenguin = nil
            }
        }
    }
    
    private func syncWithEngine() {
        // For Penguin Ball, animate emojis that are no longer in the engine
        let engineEmojiIDs = Set(gameEngine.currentEmojis.map { $0.id })
        let emojisToRemove = currentEmojis.filter { !engineEmojiIDs.contains($0.id) }
        let animatingEmojisToRemove = animatedPositionChanges.filter { !engineEmojiIDs.contains($0.id) }
        
        // Start exit animations for removed emojis that were in current display
        let screenBounds = getScreenBounds()
        for removedEmoji in emojisToRemove {
            let animatedEmoji = AnimatedEmoji(from: removedEmoji, screenBounds: screenBounds)
            animatingEmojis.append(animatedEmoji)
            
            // Remove the animated emoji after its animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + animatedEmoji.duration + 0.1) {
                self.animatingEmojis.removeAll { $0.id == animatedEmoji.id }
            }
        }
        
        // For emojis that were in position animations, interrupt them and start exit animations
        for animatingChange in animatingEmojisToRemove {
            // Cancel the position animation by removing it
            animatedPositionChanges.removeAll { $0.id == animatingChange.id }
            
            // Create a positioned emoji at the current animated position and start exit animation
            // We'll estimate the current position based on time elapsed
            let currentPosition = estimateCurrentAnimatedPosition(for: animatingChange)
            let interruptedEmoji = PositionedGameEmoji(
                id: animatingChange.id,
                emoji: animatingChange.emoji,
                type: .normal, // Default type since we can't access the original type
                position: currentPosition,
                zIndex: animatingChange.zIndex
            )
            
            let animatedEmoji = AnimatedEmoji(from: interruptedEmoji, screenBounds: screenBounds)
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
        
        // Add any new emojis that aren't positioned yet (but not if they're currently animating position changes)
        let positionedEmojiIDs = Set(currentEmojis.map { $0.id })
        let animatingEmojiIDs = Set(animatedPositionChanges.map { $0.id })
        for gameEmoji in gameEngine.currentEmojis {
            if !positionedEmojiIDs.contains(gameEmoji.id) && !animatingEmojiIDs.contains(gameEmoji.id) {
                let existingPositions = currentEmojis.map { $0.position }
                let position = positioner.generateRandomPosition(avoiding: existingPositions)
                let positionedEmoji = PositionedGameEmoji(from: gameEmoji, position: position)
                currentEmojis.append(positionedEmoji)
            }
        }
    }
    
    private func estimateCurrentAnimatedPosition(for animatedChange: AnimatedPositionChange) -> CGPoint {
        // For simplicity, assume we're halfway through the animation
        // In a more sophisticated implementation, we could track animation start times
        let progress = 0.5
        let t = progress
        let t2 = t * t
        let t3 = t2 * t
        let mt = 1.0 - t
        let mt2 = mt * mt
        let mt3 = mt2 * mt
        
        let x = mt3 * animatedChange.startPosition.x +
                3 * mt2 * t * animatedChange.controlPoint1.x +
                3 * mt * t2 * animatedChange.controlPoint2.x +
                t3 * animatedChange.endPosition.x
        
        let y = mt3 * animatedChange.startPosition.y +
                3 * mt2 * t * animatedChange.controlPoint1.y +
                3 * mt * t2 * animatedChange.controlPoint2.y +
                t3 * animatedChange.endPosition.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func getScreenBounds() -> CGRect {
        #if os(watchOS)
        // For watchOS, use WKInterfaceDevice screen bounds
        let device = WKInterfaceDevice.current()
        return device.screenBounds
        #elseif canImport(UIKit)
        // For iOS/macOS with UIKit
        return UIScreen.main.bounds
        #else
        // Fallback for other environments
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
        // Show end screen BEFORE ending the game for both game modes
        // to prevent briefly showing the main menu
        showGameEndScreen = true
        
        gameEngine.endGame()
        currentEmojis.removeAll()
        animatingEmojis.removeAll()
        animatedPositionChanges.removeAll()
        celebratingPenguin = nil
    }
    
    func dismissGameEndScreen() {
        showGameEndScreen = false
        // Ensure the game engine is properly ended
        if gameEngine.isGameActive {
            gameEngine.endGame()
        }
        // Clear all UI state
        currentEmojis.removeAll()
        animatingEmojis.removeAll()
        animatedPositionChanges.removeAll()
        celebratingPenguin = nil
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
        
        // After animations complete, set final positions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Max animation duration
            // Check if any emojis disappeared during animation - if so, don't restore them
            let currentEngineEmojiIds = Set(self.gameEngine.currentEmojis.map { $0.id })
            
            // Set final positions only for emojis that still exist in the engine
            self.currentEmojis = self.animatedPositionChanges.compactMap { change in
                // Only restore emoji if it still exists in the game engine
                if currentEngineEmojiIds.contains(change.id),
                   let engineEmoji = self.gameEngine.currentEmojis.first(where: { $0.id == change.id }) {
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
    
    func resetHighScore() {
        gameEngine.resetHighScore()
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