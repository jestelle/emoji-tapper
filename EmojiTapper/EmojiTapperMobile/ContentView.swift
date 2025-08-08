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
    let gameState: PlatformGameState
    
    var body: some View {
        VStack(spacing: 30) {
            Text("😊")
                .font(.system(size: 80))
            
            Text("Emoji Tapper")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if gameState.score > 0 {
                Text("Last Score: \(gameState.score)")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            if gameState.highScore > 0 {
                Text("High Score: \(gameState.highScore)")
                    .font(.title2)
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
                    // Timer progress bar
                    HStack {
                        ProgressView(value: gameState.timeRemaining, total: gameState.currentLevel.initialTime)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(x: 1, y: 4, anchor: .center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60) // Account for status bar
                    
                    Spacer()
                    
                    // Score in lower left corner
                    HStack {
                        Text("Score: \(gameState.score)")
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
            }
        }
    }
}

#Preview {
    ContentView()
}
