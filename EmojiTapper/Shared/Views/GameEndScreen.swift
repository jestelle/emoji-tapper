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
    let onDismiss: () -> Void
    
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
                    
                    // Continue Button
                    Button("Continue") {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                    .padding(.top)
                }
                .padding()
            }
        }
    }
}

struct GameEndScreenWatch: View {
    let totalScore: Int
    let roundScores: [Int]
    let highScore: Int
    let isNewHighScore: Bool
    let onDismiss: () -> Void
    
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
                
                // Continue Button
                Button("Continue") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            }
            .padding()
        }
    }
}