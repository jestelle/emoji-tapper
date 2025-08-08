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
            
            if gameState.isGameActive {
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
            
            Text("Emoji Tapper")
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
            
            if gameState.score > 0 {
                Text("Last: \(gameState.score)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if gameState.highScore > 0 {
                Text("High: \(gameState.highScore)")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
            
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
                ForEach(gameState.currentEmojis.sorted(by: { $0.zIndex < $1.zIndex })) { emoji in
                    Text(emoji.emoji)
                        .font(.system(size: 40))
                        .position(emoji.position)
                        .zIndex(Double(emoji.zIndex))
                        .onTapGesture {
                            gameState.emojiTapped(emoji)
                        }
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
