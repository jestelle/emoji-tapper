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
            Color.black.ignoresSafeArea()
            
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
        VStack(spacing: 12) {
            Text(gameState.selectedGameMode == .classic ? "😊" : "🐧")
                .font(.system(size: 35))
            
            Text(gameState.selectedGameMode == .classic ? "Emoji Tapper" : "Penguin Ball")
                .font(.headline)
                .foregroundColor(.white)
            
            // Game mode picker
            Picker("Game Mode", selection: $gameState.selectedGameMode) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    Text(mode.displayName)
                        .tag(mode)
                }
            }
            .pickerStyle(.menu)
            .font(.caption)
            
            // Reserve space for scores to prevent layout shifts
            Text(gameState.score > 0 ? "Last: \(gameState.score)" : " ")
                .font(.caption2)
                .foregroundColor(.gray)
                .opacity(gameState.score > 0 ? 1.0 : 0.0)
            
            Text(gameState.highScore > 0 ? "High: \(gameState.highScore)" : " ")
                .font(.caption2)
                .foregroundColor(.yellow)
                .opacity(gameState.highScore > 0 ? 1.0 : 0.0)
            
            Button("Start Game") {
                gameState.startGame()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
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
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Score in lower left corner
                    HStack {
                        Text("\(gameState.score)")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // Emojis (sorted by zIndex so higher z-index renders on top and gets priority for taps)
                // Exclude celebrating penguin from regular emojis to avoid double display
                ForEach(gameState.currentEmojis.filter { emoji in
                    gameState.celebratingPenguin?.id != emoji.id
                }.sorted(by: { $0.zIndex < $1.zIndex })) { emoji in
                    Text(emoji.emoji)
                        .font(.system(size: 40))
                        .position(emoji.position)
                        .zIndex(Double(emoji.zIndex))
                        .onTapGesture {
                            gameState.emojiTapped(emoji)
                        }
                }
                
                // Celebrating penguin (grown and staying in place)
                if let celebratingPenguin = gameState.celebratingPenguin {
                    CelebratingPenguinView(penguin: celebratingPenguin, fontSize: 40)
                }
                
                // Animated emojis flying off screen
                ForEach(gameState.animatingEmojis) { animatedEmoji in
                    AnimatedEmojiView(animatedEmoji: animatedEmoji, fontSize: 40)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
