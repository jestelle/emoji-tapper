//
//  ContentView.swift
//  EmojiTapper Watch App
//
//  Created by Josh Estelle on 7/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()
    
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
    let gameState: GameState
    
    var body: some View {
        VStack(spacing: 15) {
            Text("😊")
                .font(.system(size: 40))
            
            Text("Emoji Tapper")
                .font(.headline)
                .foregroundColor(.white)
            
            if gameState.score > 0 {
                Text("Last: \(gameState.score)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if gameState.highScore > 0 {
                Text("High: \(gameState.highScore)")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
            
            Button("Start Game") {
                gameState.startGame()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct GameView: View {
    let gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Timer progress bar and Score HUD
                VStack {
                    // Timer progress bar
                    HStack {
                        ProgressView(value: gameState.timeRemaining, total: gameState.currentLevel.initialTime)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal)
                    
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
                        .font(.system(size: 30 * gameState.emojiSizeMultiplier))
                        .opacity(gameState.emojiOpacity)
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
