//
//  LeaderboardView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

#if os(watchOS)
struct LeaderboardView: View {
    @State private var leaderboardService = LeaderboardService()
    @State private var selectedMode: GameMode
    let initialMode: GameMode?
    
    init(initialMode: GameMode? = nil) {
        self.initialMode = initialMode
        self._selectedMode = State(initialValue: initialMode ?? .classic)
    }
    @State private var topScores: [HighScore] = []
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Mode Selector
                Picker("Mode", selection: $selectedMode) {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .onChange(of: selectedMode) { _, _ in
                    Task {
                        await refreshTopScores()
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    // Top Scores (compact)
                    VStack(spacing: 8) {
                        Text("🏆 Top 5")
                            .font(.headline)
                        
                        ForEach(Array(topScores.enumerated()), id: \.element.id) { index, score in
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
            await refreshTopScores()
        }
    }
    
    @MainActor
    private func refreshTopScores() async {
        isLoading = true
        
        let success = await leaderboardService.getTopScores(mode: selectedMode, limit: 5)
        if success {
            topScores = leaderboardService.topScores
        }
        
        isLoading = false
    }
}
#else
struct LeaderboardView: View {
    @State private var leaderboardService = LeaderboardService()
    @State private var selectedMode: GameMode
    let initialMode: GameMode?
    
    init(initialMode: GameMode? = nil) {
        self.initialMode = initialMode
        self._selectedMode = State(initialValue: initialMode ?? .classic)
    }
    @State private var selectedPeriod: TimePeriod = .allTime
    @State private var playerName: String = ""
    @State private var showingPlayerNameAlert = false
    @State private var scoreToSubmit: Int?
    @State private var topScores: [HighScore] = []
    @State private var leaderboardStats: LeaderboardStats? = nil
    @State private var isLoading = false
    @State private var lastError: String? = nil
    @Environment(\.dismiss) private var dismiss
    
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
                        await refreshLeaderboard()
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
                        await refreshTopScores()
                    }
                }
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView("Loading leaderboard...")
                        .progressViewStyle(.circular)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Top Scores Section (moved first)
                            TopScoresSection(scores: topScores)
                            
                            // Stats Section (moved after top scores)
                            if let stats = leaderboardStats {
                                StatsSection(stats: stats)
                            }
                            
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
                #if !os(watchOS) && !os(macOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Refresh") {
                        Task {
                            await refreshLeaderboard()
                        }
                    }
                }
                #endif
            }
            .alert("Leaderboard Error", isPresented: .constant(lastError != nil)) {
                Button("OK") {
                    lastError = nil
                }
            } message: {
                Text(lastError ?? "")
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
                                await refreshLeaderboard()
                            }
                        }
                    }
                }
            } message: {
                Text("Enter your name to submit your score to the leaderboard")
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 600)
        #endif
        .task {
            await refreshLeaderboard()
        }
    }
    
    func submitScore(_ score: Int) {
        scoreToSubmit = score
        showingPlayerNameAlert = true
    }
    
    @MainActor
    private func refreshLeaderboard() async {
        isLoading = true
        
        let scoresSuccess = await leaderboardService.getTopScores(mode: selectedMode, period: selectedPeriod)
        let statsSuccess = await leaderboardService.getLeaderboardStats(mode: selectedMode)
        
        if scoresSuccess {
            topScores = leaderboardService.topScores
        }
        
        if statsSuccess {
            leaderboardStats = leaderboardService.leaderboardStats
        }
        
        if !scoresSuccess || !statsSuccess {
            lastError = leaderboardService.lastError
        }
        
        isLoading = false
    }
    
    @MainActor
    private func refreshTopScores() async {
        isLoading = true
        
        let success = await leaderboardService.getTopScores(mode: selectedMode, period: selectedPeriod)
        if success {
            topScores = leaderboardService.topScores
        } else {
            lastError = leaderboardService.lastError
        }
        
        isLoading = false
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
#endif

#Preview {
    LeaderboardView()
}