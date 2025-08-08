//
//  ContentView.swift
//  EmojiTapperMobile
//
//  Created by Josh Estelle on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = PlatformGameState(positioner: iOSEmojiPositioner())
    
    var body: some View {
        ZStack {
            Color.primary.colorInvert().ignoresSafeArea()
            
            if gameState.showGameEndScreen {
                GameEndScreen(
                    totalScore: gameState.score,
                    roundScores: gameState.roundScores,
                    highScore: gameState.highScore,
                    isNewHighScore: gameState.score == gameState.highScore && gameState.score > 0,
                    onDismiss: {
                        gameState.dismissGameEndScreen()
                    }
                )
            } else if gameState.isGameActive {
                iOSGameView(gameState: gameState)
            } else {
                iOSMenuView(gameState: gameState)
            }
        }
    }
}

struct iOSMenuView: View {
    @Bindable var gameState: PlatformGameState
    
    var body: some View {
        VStack(spacing: 25) {
            Text(gameState.selectedGameMode == .classic ? "😊" : "🐧")
                .font(.system(size: 80))
            
            Text(gameState.selectedGameMode == .classic ? "Emoji Tapper" : "Penguin Ball")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Game mode picker
            Picker("Game Mode", selection: $gameState.selectedGameMode) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    Text(mode.displayName)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Text(gameState.selectedGameMode.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Reserve space for scores to prevent layout shifts
            Text(gameState.score > 0 ? "Last Score: \(gameState.score)" : " ")
                .font(.title3)
                .foregroundColor(.gray)
                .opacity(gameState.score > 0 ? 1.0 : 0.0)
            
            Text(gameState.highScore > 0 ? "High Score: \(gameState.highScore)" : " ")
                .font(.title3)
                .foregroundColor(.yellow)
                .opacity(gameState.highScore > 0 ? 1.0 : 0.0)
            
            Button("Start Game") {
                gameState.startGame()
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .padding()
        }
    }
}

struct iOSGameView: View {
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
                                .scaleEffect(x: 1, y: 4, anchor: .center)
                        }
                        .padding(.horizontal)
                        .padding(.top, 60) // Account for status bar
                    } else {
                        HStack {
                            Text(gameState.gameStateText)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 60) // Account for status bar
                    }
                    
                    Spacer()
                    
                    // Score in lower left corner
                    HStack {
                        Text("\(gameState.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50) // Account for home indicator
                }
                
                // Emojis (sorted by zIndex so higher z-index renders on top and gets priority for taps)
                // Exclude celebrating penguin from regular emojis to avoid double display
                ForEach(gameState.currentEmojis.filter { emoji in
                    gameState.celebratingPenguin?.id != emoji.id
                }.sorted(by: { $0.zIndex < $1.zIndex })) { emoji in
                    DancingEmojiView(
                        emoji: emoji.emoji,
                        basePosition: emoji.position,
                        fontSize: 60, // Larger for iPhone
                        zIndex: Double(emoji.zIndex),
                        onTap: {
                            gameState.emojiTapped(emoji)
                        }
                    )
                }
                
                // Celebrating penguin (grown and staying in place)
                if let celebratingPenguin = gameState.celebratingPenguin {
                    CelebratingPenguinView(penguin: celebratingPenguin, fontSize: 60)
                }
                
                // Animated emojis flying off screen
                ForEach(gameState.animatingEmojis) { animatedEmoji in
                    AnimatedEmojiView(animatedEmoji: animatedEmoji, fontSize: 60)
                }
                
                // Animated position changes (wrong emoji taps in Penguin Ball)
                ForEach(gameState.animatedPositionChanges) { animatedChange in
                    AnimatedPositionChangeView(
                        animatedChange: animatedChange,
                        fontSize: 60,
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
