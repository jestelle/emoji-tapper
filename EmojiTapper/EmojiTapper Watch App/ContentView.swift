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
                
                // Emoji
                Text(gameState.currentEmoji)
                    .font(.system(size: 30))
                    .position(gameState.emojiPosition)
                    .onTapGesture {
                        gameState.emojiTapped()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
