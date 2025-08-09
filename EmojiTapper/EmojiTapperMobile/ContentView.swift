//
//  ContentView.swift
//  EmojiTapperMobile
//
//  Created by Josh Estelle on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = PlatformGameState(positioner: iOSEmojiPositioner())
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
                iOSGameView(gameState: gameState)
            } else {
                iOSMenuView(gameState: gameState, showingLeaderboard: $showingLeaderboard)
            }
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView(initialMode: gameState.selectedGameMode)
        }
    }
}

struct iOSMenuView: View {
    @Bindable var gameState: PlatformGameState
    @Binding var showingLeaderboard: Bool
    
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
            
            HighScoreResetView(
                highScore: gameState.highScore,
                onReset: {
                    gameState.resetHighScore()
                },
                font: .title3,
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
                    } else if gameState.selectedGameMode == .penguinBall {
                        // Round indicators for Penguin Ball
                        HStack {
                            RoundIndicatorsView(
                                currentRound: gameState.currentRoundNumber,
                                totalRounds: gameState.totalRounds,
                                roundScores: gameState.roundScores,
                                currentRoundPoints: gameState.currentRoundPoints
                            )
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

struct RoundIndicatorsView: View {
    let currentRound: Int
    let totalRounds: Int
    let roundScores: [Int]
    let currentRoundPoints: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalRounds, id: \.self) { roundNumber in
                RoundIndicatorBox(
                    roundNumber: roundNumber,
                    currentRound: currentRound,
                    roundScores: roundScores,
                    currentRoundPoints: currentRoundPoints
                )
            }
        }
    }
}

struct RoundIndicatorBox: View {
    let roundNumber: Int
    let currentRound: Int
    let roundScores: [Int]
    let currentRoundPoints: Int
    
    private var roundState: RoundState {
        if roundNumber < currentRound {
            return .completed
        } else if roundNumber == currentRound {
            return .current
        } else {
            return .upcoming
        }
    }
    
    private var displayText: String {
        switch roundState {
        case .completed:
            let scoreIndex = roundNumber - 1
            return scoreIndex < roundScores.count ? "\(roundScores[scoreIndex])" : "0"
        case .current:
            return "\(currentRoundPoints)"
        case .upcoming:
            return "—"
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.black)
            .frame(width: 80, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(roundState.backgroundColor)
                    .stroke(roundState.borderColor, style: StrokeStyle(lineWidth: 2, dash: roundState.dashPattern))
            )
    }
    
    private enum RoundState {
        case completed
        case current  
        case upcoming
        
        var backgroundColor: Color {
            switch self {
            case .completed: return .gray
            case .current: return .green
            case .upcoming: return .clear
            }
        }
        
        var borderColor: Color {
            switch self {
            case .completed: return .gray
            case .current: return .green
            case .upcoming: return .gray
            }
        }
        
        var dashPattern: [CGFloat] {
            switch self {
            case .completed: return []
            case .current: return []
            case .upcoming: return [3, 3]
            }
        }
    }
}

#Preview {
    ContentView()
}
