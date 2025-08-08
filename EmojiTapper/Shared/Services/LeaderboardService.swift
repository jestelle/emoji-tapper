//
//  LeaderboardService.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation

@Observable
class LeaderboardService {
    private let baseURL = "https://us-central1-top-leaderboard.cloudfunctions.net"
    private let gameName = "Emoji Tapper"
    
    // Current platform - will be set based on the target
    var currentPlatform: Platform = .iOS
    
    // Loading states
    var isLoading = false
    var lastError: String?
    
    // Cached data
    var topScores: [HighScore] = []
    var playerBest: HighScore?
    var leaderboardStats: LeaderboardStats?
    
    init() {
        #if os(iOS)
        currentPlatform = .iOS
        #elseif os(macOS)
        currentPlatform = .macOS
        #elseif os(watchOS)
        currentPlatform = .watchOS
        #endif
    }
    
    // MARK: - Submit Score
    
    func submitScore(mode: GameMode, player: String, score: Int) async -> Bool {
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/submitScore")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "game": gameName,
            "mode": mode.rawValue,
            "platform": currentPlatform.rawValue,
            "player": player,
            "score": score
        ] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("🌐 Submitting score to: \(url)")
            
            // Add timeout configuration
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            let session = URLSession(configuration: config)
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 201 {
                    let submitResponse = try JSONDecoder().decode(SubmitScoreResponse.self, from: data)
                    return submitResponse.success
                } else {
                    let errorResponse = try JSONDecoder().decode(SubmitScoreResponse.self, from: data)
                    lastError = errorResponse.error ?? "Failed to submit score (HTTP \(httpResponse.statusCode))"
                    return false
                }
            }
            
            lastError = "Invalid response"
            return false
            
        } catch {
            print("❌ Network error: \(error)")
            
            // Handle specific sandbox errors
            if error.localizedDescription.contains("Sandbox") || error.localizedDescription.contains("networkd") {
                lastError = "Network access blocked by sandbox. Please check app permissions."
            } else {
                lastError = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Get Top Scores
    
    func getTopScores(mode: GameMode, period: TimePeriod = .allTime, limit: Int = 10) async -> Bool {
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        var components = URLComponents(string: "\(baseURL)/getTopScores")!
        components.queryItems = [
            URLQueryItem(name: "game", value: gameName),
            URLQueryItem(name: "mode", value: mode.rawValue),
            URLQueryItem(name: "platform", value: currentPlatform.rawValue),
            URLQueryItem(name: "period", value: period.rawValue),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = components.url else {
            lastError = "Invalid URL"
            return false
        }
        
        do {
            print("🌐 Getting top scores from: \(url)")
            
            // Add timeout configuration
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            let session = URLSession(configuration: config)
            
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    let topScoresResponse = try JSONDecoder().decode(TopScoresResponse.self, from: data)
                    if topScoresResponse.success {
                        topScores = topScoresResponse.scores
                        return true
                    } else {
                        lastError = topScoresResponse.error ?? "Failed to get top scores"
                        return false
                    }
                } else {
                    let errorResponse = try JSONDecoder().decode(TopScoresResponse.self, from: data)
                    lastError = errorResponse.error ?? "Failed to get top scores (HTTP \(httpResponse.statusCode))"
                    return false
                }
            }
            
            lastError = "Invalid response"
            return false
            
        } catch {
            print("❌ Network error: \(error)")
            
            // Handle specific sandbox errors
            if error.localizedDescription.contains("Sandbox") || error.localizedDescription.contains("networkd") {
                lastError = "Network access blocked by sandbox. Please check app permissions."
            } else {
                lastError = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Get Player Best
    
    func getPlayerBest(mode: GameMode, player: String) async -> Bool {
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        var components = URLComponents(string: "\(baseURL)/getPlayerBest")!
        components.queryItems = [
            URLQueryItem(name: "game", value: gameName),
            URLQueryItem(name: "mode", value: mode.rawValue),
            URLQueryItem(name: "platform", value: currentPlatform.rawValue),
            URLQueryItem(name: "player", value: player)
        ]
        
        guard let url = components.url else {
            lastError = "Invalid URL"
            return false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let playerBestResponse = try JSONDecoder().decode(PlayerBestResponse.self, from: data)
                    if playerBestResponse.success {
                        playerBest = playerBestResponse.playerBest
                        return true
                    } else {
                        lastError = playerBestResponse.error ?? "Failed to get player best"
                        return false
                    }
                } else {
                    let errorResponse = try JSONDecoder().decode(PlayerBestResponse.self, from: data)
                    lastError = errorResponse.error ?? "Failed to get player best"
                    return false
                }
            }
            
            lastError = "Invalid response"
            return false
            
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Get Leaderboard Stats
    
    func getLeaderboardStats(mode: GameMode) async -> Bool {
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        var components = URLComponents(string: "\(baseURL)/getLeaderboardStats")!
        components.queryItems = [
            URLQueryItem(name: "game", value: gameName),
            URLQueryItem(name: "mode", value: mode.rawValue),
            URLQueryItem(name: "platform", value: currentPlatform.rawValue)
        ]
        
        guard let url = components.url else {
            lastError = "Invalid URL"
            return false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let statsResponse = try JSONDecoder().decode(LeaderboardStatsResponse.self, from: data)
                    if statsResponse.success {
                        leaderboardStats = statsResponse.stats
                        return true
                    } else {
                        lastError = statsResponse.error ?? "Failed to get leaderboard stats"
                        return false
                    }
                } else {
                    let errorResponse = try JSONDecoder().decode(LeaderboardStatsResponse.self, from: data)
                    lastError = errorResponse.error ?? "Failed to get leaderboard stats"
                    return false
                }
            }
            
            lastError = "Invalid response"
            return false
            
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        lastError = nil
    }
    
    func refreshLeaderboard(mode: GameMode) async {
        await getTopScores(mode: mode)
        await getLeaderboardStats(mode: mode)
    }
    
    // MARK: - Test Connection
    
    func testConnection() async -> Bool {
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/getTopScores?game=\(gameName)&mode=Classic&platform=\(currentPlatform.rawValue)&period=all_time&limit=1")!
        
        do {
            print("🌐 Testing connection to: \(url)")
            
            // Add timeout configuration
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            let session = URLSession(configuration: config)
            
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Test response status: \(httpResponse.statusCode)")
                return httpResponse.statusCode == 200
            }
            
            return false
            
        } catch {
            print("❌ Test connection error: \(error)")
            
            // Handle specific sandbox errors
            if error.localizedDescription.contains("Sandbox") || error.localizedDescription.contains("networkd") {
                lastError = "Network access blocked by sandbox. Please check app permissions."
            } else {
                lastError = "Connection test failed: \(error.localizedDescription)"
            }
            return false
        }
    }
}
