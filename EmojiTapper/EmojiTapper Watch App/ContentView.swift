//
//  ContentView.swift
//  EmojiTapper Watch App
//
//  Created by Josh Estelle on 7/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = PlatformGameState(positioner: WatchEmojiPositioner())
    
    var body: some View {
        ZStack {
            Color.primary.colorInvert().ignoresSafeArea()
            
            if gameState.showGameEndScreen {
                GameEndScreenWatch(
                    totalScore: gameState.score,
                    roundScores: gameState.roundScores,
                    highScore: gameState.highScore,
                    isNewHighScore: gameState.score == gameState.highScore && gameState.score > 0,
                    onDismiss: {
                        gameState.dismissGameEndScreen()
                    }
                )
            } else if gameState.isGameActive {
                GameView(gameState: gameState)
            } else {
                MenuView(gameState: gameState)
            }
        }
    }
}

struct MenuView: View {
    @Bindable var gameState: PlatformGameState
    
    var body: some View {
        VStack(spacing: 8) {
            // Game mode selector as tappable icons
            HStack(spacing: 20) {
                // Classic Mode
                VStack(spacing: 4) {
                    Text("😊")
                        .font(.system(size: 30))
                        .opacity(gameState.selectedGameMode == .classic ? 1.0 : 0.4)
                    Text("Classic")
                        .font(.caption2)
                        .foregroundColor(gameState.selectedGameMode == .classic ? .primary : .secondary)
                }
                .onTapGesture {
                    gameState.selectedGameMode = .classic
                }
                
                // Penguin Ball Mode
                VStack(spacing: 4) {
                    Text("🐧")
                        .font(.system(size: 30))
                        .opacity(gameState.selectedGameMode == .penguinBall ? 1.0 : 0.4)
                    Text("Penguin")
                        .font(.caption2)
                        .foregroundColor(gameState.selectedGameMode == .penguinBall ? .primary : .secondary)
                }
                .onTapGesture {
                    gameState.selectedGameMode = .penguinBall
                }
            }
            .padding(.top, 4)
            
            // Compact scores with smaller text
            VStack(spacing: 2) {
                Text(gameState.score > 0 ? "Last: \(gameState.score)" : " ")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .opacity(gameState.score > 0 ? 1.0 : 0.0)
                
                Text(gameState.highScore > 0 ? "High: \(gameState.highScore)" : " ")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                    .opacity(gameState.highScore > 0 ? 1.0 : 0.0)
            }
            .padding(.vertical, 4)
            
            Button("Start Game") {
                gameState.startGame()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
        .padding(.bottom, 8) // Extra padding to ensure button is visible
    }
}

struct GameView: View {
    let gameState: PlatformGameState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Timer progress bar and Score HUD
                VStack {
                    // Progress bar for Classic mode, text info for other modes
                    if gameState.selectedGameMode == .classic {
                        HStack {
                            ProgressView(value: gameState.timeRemainingForProgress, total: gameState.totalTimeForProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Text(gameState.gameStateText)
                                .font(.caption2)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Score in lower left corner
                    HStack {
                        Text("\(gameState.score)")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // Emojis (sorted by zIndex so higher z-index renders on top and gets priority for taps)
                // Exclude celebrating penguin from regular emojis to avoid double display
                ForEach(gameState.currentEmojis.filter { emoji in
                    gameState.celebratingPenguin?.id != emoji.id
                }.sorted(by: { $0.zIndex < $1.zIndex })) { emoji in
                    DancingEmojiView(
                        emoji: emoji.emoji,
                        basePosition: emoji.position,
                        fontSize: 30, // 25% smaller (40 * 0.75 = 30)
                        zIndex: Double(emoji.zIndex),
                        onTap: {
                            gameState.emojiTapped(emoji)
                        }
                    )
                }
                
                // Celebrating penguin (grown and staying in place)
                if let celebratingPenguin = gameState.celebratingPenguin {
                    CelebratingPenguinView(penguin: celebratingPenguin, fontSize: 30)
                }
                
                // Animated emojis flying off screen
                ForEach(gameState.animatingEmojis) { animatedEmoji in
                    AnimatedEmojiView(animatedEmoji: animatedEmoji, fontSize: 30)
                }
                
                // Animated position changes (wrong emoji taps in Penguin Ball)
                ForEach(gameState.animatedPositionChanges) { animatedChange in
                    AnimatedPositionChangeView(
                        animatedChange: animatedChange,
                        fontSize: 30,
                        onComplete: {
                            // Individual animations will clean themselves up via the timer
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
