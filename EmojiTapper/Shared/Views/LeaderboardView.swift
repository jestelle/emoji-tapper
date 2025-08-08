//
//  LeaderboardView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var leaderboardService = LeaderboardService()
    @State private var selectedMode: GameMode = .classic
    @State private var selectedPeriod: TimePeriod = .allTime
    @State private var playerName: String = ""
    @State private var showingPlayerNameAlert = false
    @State private var scoreToSubmit: Int?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode Selector
                Picker("Game Mode", selection: $selectedMode) {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedMode) { _, _ in
                    Task {
                        await leaderboardService.refreshLeaderboard(mode: selectedMode)
                    }
                }
                
                // Period Selector
                Picker("Time Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedPeriod) { _, _ in
                    Task {
                        await leaderboardService.getTopScores(mode: selectedMode, period: selectedPeriod)
                    }
                }
                
                // Content
                if leaderboardService.isLoading {
                    Spacer()
                    ProgressView("Loading leaderboard...")
                        .progressViewStyle(.circular)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats Section
                            if let stats = leaderboardService.leaderboardStats {
                                StatsSection(stats: stats)
                            }
                            
                            // Top Scores Section
                            TopScoresSection(scores: leaderboardService.topScores)
                            
                            // Player Best Section
                            if let playerBest = leaderboardService.playerBest {
                                PlayerBestSection(playerBest: playerBest)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("🏆 Leaderboard")
            #if !os(watchOS) && !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if !os(macOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await leaderboardService.refreshLeaderboard(mode: selectedMode)
                        }
                    }
                }
                #endif
            }
            .alert("Leaderboard Error", isPresented: .constant(leaderboardService.lastError != nil)) {
                Button("OK") {
                    leaderboardService.clearError()
                }
            } message: {
                Text(leaderboardService.lastError ?? "")
            }
            .alert("Submit Score", isPresented: $showingPlayerNameAlert) {
                TextField("Your Name", text: $playerName)
                Button("Cancel", role: .cancel) { }
                Button("Submit") {
                    if let score = scoreToSubmit, !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Task {
                            let success = await leaderboardService.submitScore(
                                mode: selectedMode,
                                player: playerName.trimmingCharacters(in: .whitespacesAndNewlines),
                                score: score
                            )
                            if success {
                                await leaderboardService.refreshLeaderboard(mode: selectedMode)
                            }
                        }
                    }
                }
            } message: {
                Text("Enter your name to submit your score to the leaderboard")
            }
        }
        .task {
            await leaderboardService.refreshLeaderboard(mode: selectedMode)
        }
    }
    
    func submitScore(_ score: Int) {
        scoreToSubmit = score
        showingPlayerNameAlert = true
    }
}

// MARK: - Supporting Views

struct StatsSection: View {
    let stats: LeaderboardStats
    
    var body: some View {
        VStack(spacing: 12) {
            Text("📊 Statistics")
                .font(.headline)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Total Scores", value: "\(stats.totalScores)")
                StatCard(title: "Players", value: "\(stats.uniquePlayers)")
                StatCard(title: "Highest Score", value: "\(stats.highestScore)")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct TopScoresSection: View {
    let scores: [HighScore]
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🏆 Top Scores")
                .font(.headline)
                .foregroundColor(.gray)
            
            if scores.isEmpty {
                Text("No scores yet")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                        ScoreRow(
                            rank: index + 1,
                            player: score.player,
                            score: score.score,
                            isTopThree: index < 3
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ScoreRow: View {
    let rank: Int
    let player: String
    let score: Int
    let isTopThree: Bool
    
    var body: some View {
        HStack {
            // Rank
            Text("#\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isTopThree ? .yellow : .gray)
                .frame(width: 40, alignment: .leading)
            
            // Player Name
            Text(player)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Score
            Text("\(score)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isTopThree ? Color.yellow.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct PlayerBestSection: View {
    let playerBest: HighScore
    
    var body: some View {
        VStack(spacing: 12) {
            Text("👤 Your Best")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(playerBest.player)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Your personal best")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(playerBest.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Watch Version

struct LeaderboardViewWatch: View {
    @State private var leaderboardService = LeaderboardService()
    @State private var selectedMode: GameMode = .classic
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Mode Selector
                Picker("Mode", selection: $selectedMode) {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedMode) { _, _ in
                    Task {
                        await leaderboardService.getTopScores(mode: selectedMode, limit: 5)
                    }
                }
                
                if leaderboardService.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    // Top Scores (compact)
                    VStack(spacing: 8) {
                        Text("🏆 Top 5")
                            .font(.headline)
                        
                        ForEach(Array(leaderboardService.topScores.enumerated()), id: \.element.id) { index, score in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 25, alignment: .leading)
                                
                                Text(score.player)
                                    .font(.caption)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(score.score)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Leaderboard")
        .task {
            await leaderboardService.getTopScores(mode: selectedMode, limit: 5)
        }
    }
}

#Preview {
    LeaderboardView()
}
