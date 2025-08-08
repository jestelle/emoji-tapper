//
//  ContentView.swift
//  EmojiTapperMac
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = PlatformGameState(positioner: macOSEmojiPositioner())
    @State private var showingLeaderboard = false
    
    var body: some View {
        ZStack {
            Color.primary.colorInvert().ignoresSafeArea()
            
            if gameState.showGameEndScreen {
                GameEndScreen(
                    totalScore: gameState.score,
                    roundScores: gameState.roundScores,
                    highScore: gameState.highScore,
                    isNewHighScore: gameState.score == gameState.highScore && gameState.score > 0,
                    gameMode: gameState.selectedGameMode,
                    onDismiss: {
                        gameState.dismissGameEndScreen()
                    }
                )
            } else if gameState.isGameActive {
                MacGameView(gameState: gameState)
            } else {
                MacMenuView(gameState: gameState, showingLeaderboard: $showingLeaderboard)
            }
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
        }
    }
}

struct MacMenuView: View {
    @Bindable var gameState: PlatformGameState
    @Binding var showingLeaderboard: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text(gameState.selectedGameMode == .classic ? "😊" : "🐧")
                .font(.system(size: 100))
            
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
            .frame(width: 300)
            
            Text(gameState.selectedGameMode.description)
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            // Reserve space for scores to prevent layout shifts
            Text(gameState.score > 0 ? "Last Score: \(gameState.score)" : " ")
                .font(.title2)
                .foregroundColor(.gray)
                .opacity(gameState.score > 0 ? 1.0 : 0.0)
            
            HighScoreResetView(
                highScore: gameState.highScore,
                onReset: {
                    gameState.resetHighScore()
                },
                font: .title2,
                color: .yellow,
                format: "High Score: %d"
            )
            
            VStack(spacing: 12) {
                Button("Start Game") {
                    gameState.startGame()
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                
                Button("🏆 Leaderboard") {
                    showingLeaderboard = true
                }
                .buttonStyle(.bordered)
                .font(.title3)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MacGameView: View {
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
                                .scaleEffect(x: 1, y: 6, anchor: .center)
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                    } else {
                        HStack {
                            Text(gameState.gameStateText)
                                .font(.title2)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // Score in lower left corner
                    HStack {
                        Text("\(gameState.score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 30)
                }
                
                // Emojis (sorted by zIndex so higher z-index renders on top and gets priority for taps)
                // Exclude celebrating penguin from regular emojis to avoid double display
                ForEach(gameState.currentEmojis.filter { emoji in
                    gameState.celebratingPenguin?.id != emoji.id
                }.sorted(by: { $0.zIndex < $1.zIndex })) { emoji in
                    DancingEmojiView(
                        emoji: emoji.emoji,
                        basePosition: emoji.position,
                        fontSize: 50, // Good size for Mac
                        zIndex: Double(emoji.zIndex),
                        onTap: {
                            gameState.emojiTapped(emoji)
                        }
                    )
                }
                
                // Celebrating penguin (grown and staying in place)
                if let celebratingPenguin = gameState.celebratingPenguin {
                    CelebratingPenguinView(penguin: celebratingPenguin, fontSize: 50)
                }
                
                // Animated emojis flying off screen
                ForEach(gameState.animatingEmojis) { animatedEmoji in
                    AnimatedEmojiView(animatedEmoji: animatedEmoji, fontSize: 50)
                }
                
                // Animated position changes (wrong emoji taps in Penguin Ball)
                ForEach(gameState.animatedPositionChanges) { animatedChange in
                    AnimatedPositionChangeView(
                        animatedChange: animatedChange,
                        fontSize: 50,
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
