//
//  LeaderboardModels.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation

// MARK: - Models

struct HighScore: Codable, Identifiable {
    let id: String
    let game: String
    let mode: String
    let platform: String
    let player: String
    let score: Int
    let datetime: String
    
    enum CodingKeys: String, CodingKey {
        case id, game, mode, platform, player, score, datetime
    }
}

struct LeaderboardStats: Codable {
    let totalScores: Int
    let uniquePlayers: Int
    let highestScore: Int
    let averageScore: Int
    let game: String
    let mode: String
    let platform: String
}

struct LeaderboardResponse<T: Codable>: Codable {
    let success: Bool
    let error: String?
}

struct SubmitScoreResponse: Codable {
    let success: Bool
    let id: String?
    let message: String?
    let error: String?
}

struct TopScoresResponse: Codable {
    let success: Bool
    let scores: [HighScore]
    let count: Int
    let period: String
    let game: String
    let mode: String
    let platform: String
    let error: String?
}

struct PlayerBestResponse: Codable {
    let success: Bool
    let playerBest: HighScore?
    let message: String?
    let error: String?
}

struct LeaderboardStatsResponse: Codable {
    let success: Bool
    let stats: LeaderboardStats?
    let error: String?
}

// MARK: - Platform Enum

enum Platform: String, CaseIterable {
    case iOS = "iOS"
    case macOS = "macOS"
    case watchOS = "watchOS"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Time Period Enum

enum TimePeriod: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    case allTime = "all_time"
    
    var displayName: String {
        switch self {
        case .day: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .allTime: return "All Time"
        }
    }
}
