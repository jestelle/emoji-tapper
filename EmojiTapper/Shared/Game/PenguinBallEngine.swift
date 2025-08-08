//
//  PenguinBallEngine.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
import Foundation

@Observable
class PenguinBallEngine: GameModeEngine {
    let gameMode: GameMode = .penguinBall
    var score: Int = 0
    var isGameActive: Bool = false
    var currentEmojis: [GameEmoji] = []
    var highScore: Int = 0 {
        didSet {
            saveHighScore()
        }
    }
    
    // Penguin Ball specific properties
    private var currentRound: Int = 0
    private let maxRounds: Int = 5
    private var timeUntilDisappear: TimeInterval = 1.0
    private var totalEmojis: Int = 0
    private var emojisRemaining: Int = 0
    var roundScores: [Int] = [] // Track score for each round
    
    var gameStateText: String {
        if isGameActive {
            let roundText = "Round \(currentRound)/\(maxRounds)"
            let pointsText = "Available points: \(possiblePoints)"
            return "\(roundText) • \(pointsText)"
        }
        return ""
    }
    
    private var possiblePoints: Int {
        guard totalEmojis > 0 else { return 1 }
        let percentage = Double(emojisRemaining) / Double(totalEmojis)
        return max(1, Int(ceil(percentage * 100)))
    }
    
    private var gameTimer: Timer?
    private var disappearTimer: Timer?
    var onEmojisChanged: (() -> Void)?
    private var shouldNotifyUI: Bool = true
    
    let distractorEmojis = ["😀", "😊", "😂", "🥰", "😎", "🤔", "😮", "😋", "🙂", "😆", "😍", "🤗", "😴", "🤯", "😇", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜", "🦟", "🦗", "🕷", "🦂", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪", "🐫", "🦒", "🦘", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🦙", "🐐", "🦌", "🐕", "🐩", "🦮", "🐕‍🦺", "🐈", "🐈‍⬛", "🐓", "🦃", "🦚", "🦜", "🦢", "🦩", "🕊", "🐇", "🦝", "🦨", "🦡", "🦦", "🦫", "🐿", "🦔"]
    
    init() {
        loadHighScore()
    }
    
    func startGame() {
        score = 0
        currentRound = 0
        roundScores = []
        isGameActive = true
        startNextRound()
    }
    
    func endGame() {
        isGameActive = false
        stopAllTimers()
        
        if score > highScore {
            highScore = score
        }
    }
    
    func emojiTapped(_ emoji: GameEmoji) {
        guard isGameActive else { return }
        
        if emoji.emoji == "🐧" {
            // Found the penguin!
            let roundScore = possiblePoints
            score += roundScore
            roundScores.append(roundScore)
            stopAllTimers()
            
            if currentRound >= maxRounds {
                endGame()
            }
            // Don't automatically proceed to next round - let UI handle celebration
        } else {
            // Wrong emoji - no penalty, just continue
        }
    }
    
    func proceedToNextRound() {
        guard currentRound < maxRounds else { return }
        startNextRound()
    }
    
    func pauseTimers() {
        stopAllTimers()
    }
    
    func resumeTimers() {
        // Only resume if we haven't started disappearing yet
        if disappearTimer == nil && gameTimer == nil {
            startDisappearTimer()
        }
    }
    
    private func startNextRound() {
        currentRound += 1
        timeUntilDisappear = 1.0
        generateNewEmojis()
        startDisappearTimer()
    }
    
    private func generateNewEmojis() {
        currentEmojis.removeAll()
        
        // Generate lots of emojis - different amounts for different platforms
        let baseCount = 80 // Will be dense but manageable on all platforms
        totalEmojis = baseCount
        emojisRemaining = baseCount
        
        var zIndex = 0
        
        // Add the penguin with high z-index to ensure it's visible
        currentEmojis.append(GameEmoji(
            emoji: "🐧",
            type: .normal,
            zIndex: baseCount + 10 // Always on top or near top
        ))
        zIndex += 1
        
        // Fill with lots of distractor emojis
        for _ in 1..<baseCount {
            let randomEmoji = distractorEmojis.randomElement() ?? "😀"
            currentEmojis.append(GameEmoji(
                emoji: randomEmoji,
                type: .normal,
                zIndex: zIndex
            ))
            zIndex += 1
        }
        
        // Shuffle the array to randomize positions
        currentEmojis.shuffle()
        
        // Notify UI of emoji changes
        if shouldNotifyUI {
            onEmojisChanged?()
        }
    }
    
    private func startDisappearTimer() {
        // After 1 second, start making emojis disappear
        disappearTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.startDisappearingEmojis()
        }
    }
    
    private func startDisappearingEmojis() {
        // Remove emojis gradually (except the penguin)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.removeRandomEmojis()
        }
    }
    
    private func removeRandomEmojis() {
        guard isGameActive else { return }
        
        // Don't remove the penguin
        let nonPenguinEmojis = currentEmojis.filter { $0.emoji != "🐧" }
        
        if nonPenguinEmojis.count == 0 {
            // Only penguin left, stop removing
            stopAllTimers()
            return
        }
        
        // Remove 3-5 emojis at a time, but don't go below just the penguin
        let removeCount = min(Int.random(in: 3...5), nonPenguinEmojis.count)
        let emojisToRemove = Array(nonPenguinEmojis.shuffled().prefix(removeCount))
        
        for emojiToRemove in emojisToRemove {
            if let index = currentEmojis.firstIndex(where: { $0.id == emojiToRemove.id }) {
                currentEmojis.remove(at: index)
                emojisRemaining -= 1
            }
        }
        
        // Notify UI of emoji changes
        if shouldNotifyUI {
            onEmojisChanged?()
        }
    }
    
    private func stopAllTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        disappearTimer?.invalidate()
        disappearTimer = nil
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "EmojiTapperPenguinBallHighScore")
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "EmojiTapperPenguinBallHighScore")
    }
}