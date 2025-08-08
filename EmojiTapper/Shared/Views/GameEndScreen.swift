//
//  GameEndScreen.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct GameEndScreen: View {
    let totalScore: Int
    let roundScores: [Int]
    let highScore: Int
    let isNewHighScore: Bool
    let gameMode: GameMode
    let onDismiss: () -> Void
    
    @State private var leaderboardService = LeaderboardService()
    @State private var showingLeaderboard = false
    @State private var showingPlayerNameAlert = false
    @State private var playerName: String = ""
    @State private var scoreSubmitted = false
    
    var body: some View {
        ZStack {
            Color.primary.colorInvert().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("🐧 Game Complete! 🐧")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if isNewHighScore {
                        Text("🎉 NEW HIGH SCORE! 🎉")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Total Score
                    VStack(spacing: 8) {
                        Text("Final Score")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("\(totalScore)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(isNewHighScore ? .yellow : .primary)
                    }
                    
                    // Round Breakdown
                    VStack(spacing: 12) {
                        Text("Round Scores")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        ForEach(Array(roundScores.enumerated()), id: \.offset) { index, score in
                            HStack {
                                Text("Round \(index + 1)")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(score) pts")
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    // High Score Info
                    if !isNewHighScore && highScore > 0 {
                        VStack(spacing: 4) {
                            Text("High Score")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(highScore)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    // Leaderboard Buttons
                    VStack(spacing: 12) {
                        if !scoreSubmitted {
                            Button("Submit to Leaderboard") {
                                showingPlayerNameAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.title2)
                        } else {
                            Text("✅ Score Submitted!")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        
                        Button("View Leaderboard") {
                            showingLeaderboard = true
                        }
                        .buttonStyle(.bordered)
                        .font(.title2)
                        
                        Button("Continue") {
                            onDismiss()
                        }
                        .buttonStyle(.bordered)
                        .font(.title2)
                    }
                    .padding(.top)
                }
            .padding()
            }
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
        }
        .alert("Submit Score", isPresented: $showingPlayerNameAlert) {
            TextField("Your Name", text: $playerName)
            Button("Cancel", role: .cancel) { }
            Button("Submit") {
                if !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Task {
                        let success = await leaderboardService.submitScore(
                            mode: gameMode,
                            player: playerName.trimmingCharacters(in: .whitespacesAndNewlines),
                            score: totalScore
                        )
                        if success {
                            scoreSubmitted = true
                        }
                    }
                }
            }
        } message: {
            Text("Enter your name to submit your score")
        }
        .alert("Leaderboard Error", isPresented: .constant(leaderboardService.lastError != nil)) {
            Button("OK") {
                leaderboardService.clearError()
            }
        } message: {
            Text(leaderboardService.lastError ?? "")
        }
        
    }
}

struct GameEndScreenWatch: View {
    let totalScore: Int
    let roundScores: [Int]
    let highScore: Int
    let isNewHighScore: Bool
    let gameMode: GameMode
    let onDismiss: () -> Void
    
    @State private var leaderboardService = LeaderboardService()
    @State private var showingLeaderboard = false
    @State private var showingPlayerNameAlert = false
    @State private var playerName: String = ""
    @State private var scoreSubmitted = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Title
                Text("🐧 Complete! 🐧")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if isNewHighScore {
                    Text("🎉 NEW HIGH! 🎉")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                
                // Total Score
                Text("\(totalScore)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isNewHighScore ? .yellow : .primary)
                
                // Round Scores (compact)
                VStack(spacing: 4) {
                    ForEach(Array(roundScores.enumerated()), id: \.offset) { index, score in
                        HStack {
                            Text("R\(index + 1)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(score)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                // Leaderboard Buttons
                VStack(spacing: 8) {
                    if !scoreSubmitted {
                        Button("Submit Score") {
                            showingPlayerNameAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.caption)
                    } else {
                        Text("✅ Submitted!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Button("Leaderboard") {
                        showingLeaderboard = true
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("Continue") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardViewWatch()
        }
        .alert("Submit Score", isPresented: $showingPlayerNameAlert) {
            TextField("Your Name", text: $playerName)
            Button("Cancel", role: .cancel) { }
            Button("Submit") {
                if !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Task {
                        let success = await leaderboardService.submitScore(
                            mode: gameMode,
                            player: playerName.trimmingCharacters(in: .whitespacesAndNewlines),
                            score: totalScore
                        )
                        if success {
                            scoreSubmitted = true
                        }
                    }
                }
            }
        } message: {
            Text("Enter your name to submit your score")
        }
        .alert("Leaderboard Error", isPresented: .constant(leaderboardService.lastError != nil)) {
            Button("OK") {
                leaderboardService.clearError()
            }
        } message: {
            Text(leaderboardService.lastError ?? "")
        }
    }
}