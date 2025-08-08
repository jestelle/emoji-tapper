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
            Color.black.ignoresSafeArea()
            
            if gameState.isGameActive {
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
            
            Text("Emoji Tapper")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
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
            
            if gameState.score > 0 {
                Text("Last Score: \(gameState.score)")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            if gameState.highScore > 0 {
                Text("High Score: \(gameState.highScore)")
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            
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
                                .foregroundColor(.white)
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
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50) // Account for home indicator
                }
                
                // Emojis (sorted by zIndex so higher z-index renders on top and gets priority for taps)
                ForEach(gameState.currentEmojis.sorted(by: { $0.zIndex < $1.zIndex })) { emoji in
                    Text(emoji.emoji)
                        .font(.system(size: 60)) // Larger for iPhone
                        .position(emoji.position)
                        .zIndex(Double(emoji.zIndex))
                        .onTapGesture {
                            gameState.emojiTapped(emoji)
                        }
                }
                
                // Animated emojis flying off screen
                ForEach(gameState.animatingEmojis) { animatedEmoji in
                    AnimatedEmojiView(animatedEmoji: animatedEmoji, fontSize: 60)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
