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
            Text("🎯")
                .font(.system(size: 40))
            
            Text("Emoji Tapper")
                .font(.headline)
                .foregroundColor(.white)
            
            if gameState.score > 0 {
                Text("Score: \(gameState.score)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
                // Timer and Score HUD
                VStack {
                    HStack {
                        Text("\(Int(gameState.timeRemaining))s")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Score: \(gameState.score)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
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
