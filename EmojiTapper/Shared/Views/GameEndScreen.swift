//
//  GameEndScreen.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct GameEndScreen: View {
    let totalScore: Int
    let roundScores: [Int]
    let highScore: Int
    let isNewHighScore: Bool
    let gameMode: GameMode
    let onDismiss: () -> Void
    
    @State private var leaderboardService = LeaderboardService.shared
    @State private var showingLeaderboard = false
    @State private var playerName: String = ""
    @State private var scoreSubmitted = false
    @State private var isSubmittingScore = false
    @FocusState private var isPlayerNameFocused: Bool
    
    var body: some View {
#if os(watchOS)
        ScrollView {
            VStack(spacing: 8) {
                // Title
                Text("Complete!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if isNewHighScore {
                    Label("NEW HIGH!", systemImage: "star.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                
                // Total Score
                Text("\(totalScore)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isNewHighScore ? .yellow : .primary)
                
                // Round Scores (compact) - only show for multi-round games
                if !roundScores.isEmpty {
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
                }
                
                // Leaderboard Buttons
                VStack(spacing: 8) {
                    if !scoreSubmitted {
                        VStack(spacing: 6) {
                            TextField("Name...", text: $playerName)
                                .focused($isPlayerNameFocused)
                                .onSubmit {
                                    submitScore()
                                }
                                .disabled(isSubmittingScore)
                            
                            Button(action: {
                                submitScore()
                            }) {
                                HStack {
                                    if isSubmittingScore {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.6)
                                        Text("Submitting...")
                                            .font(.caption2)
                                    } else {
                                        Text("Submit Score")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.caption)
                            .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingScore)
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    } else {
                        Label("Submitted!", systemImage: "checkmark.circle.fill")
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
            LeaderboardView(initialMode: gameMode)
        }
        .alert("Leaderboard Error", isPresented: .constant(leaderboardService.lastError != nil)) {
            Button("OK") {
                leaderboardService.clearError()
            }
        } message: {
            Text(leaderboardService.lastError ?? "")
        }
        .onAppear {
            loadDefaultPlayerName()
        }
#else
        ZStack {
            Color.primary.colorInvert().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Game Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if isNewHighScore {
                        Label("NEW HIGH SCORE!", systemImage: "star.fill")
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
                    
                    // Round Breakdown (only show for multi-round games)
                    if !roundScores.isEmpty {
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
                    }
                    
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
                    
                    // Leaderboard Submission Section
                    VStack(spacing: 12) {
                        if !scoreSubmitted {
                            VStack(spacing: 8) {
                                TextField("Name...", text: $playerName)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($isPlayerNameFocused)
                                    .onSubmit {
                                        submitScore()
                                    }
                                    .disabled(isSubmittingScore)
                                
                                Button(action: {
                                    submitScore()
                                }) {
                                    HStack {
                                        if isSubmittingScore {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                            Text("Submitting...")
                                        } else {
                                            Text("Submit to Leaderboard")
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .font(.title2)
                                .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingScore)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        } else {
                            Label("Score Submitted!", systemImage: "checkmark.circle.fill")
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
            LeaderboardView(initialMode: gameMode)
        }
        .alert("Leaderboard Error", isPresented: .constant(leaderboardService.lastError != nil)) {
            Button("OK") {
                leaderboardService.clearError()
            }
        } message: {
            Text(leaderboardService.lastError ?? "")
        }
        .onAppear {
            loadDefaultPlayerName()
        }
#endif
    }
    
    private func loadDefaultPlayerName() {
        // Load last saved name only - don't auto-fill device name
        if let savedName = UserDefaults.standard.string(forKey: "EmojiTapperPlayerName"), !savedName.isEmpty {
            playerName = savedName
        } else {
            // Leave empty for "Name..." placeholder to show
            playerName = ""
        }
    }
    
    private func submitScore() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty && !isSubmittingScore else { return }
        
        // Save the name for future use
        UserDefaults.standard.set(trimmedName, forKey: "EmojiTapperPlayerName")
        
        isSubmittingScore = true
        Task {
            let success = await leaderboardService.submitScore(
                mode: gameMode,
                player: trimmedName,
                score: totalScore
            )
            
            isSubmittingScore = false
            if success {
                scoreSubmitted = true
                isPlayerNameFocused = false
            }
        }
    }
}
