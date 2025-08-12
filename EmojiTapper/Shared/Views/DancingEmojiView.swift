//
//  DancingEmojiView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct DancingEmojiView: View {
    let emoji: GameEmoji
    let basePosition: CGPoint
    let onTap: () -> Void
    
    @State private var danceOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var scale: Double = 1.0

    let danceSpeedScale: Double = 0.5
    
    var body: some View {
        EmojiImage(emoji: emoji)
            .frame(width: 50, height: 50)
            .position(x: basePosition.x + danceOffset.width, 
                     y: basePosition.y + danceOffset.height)
            .rotationEffect(.degrees(rotationAngle))
            .scaleEffect(scale)
            .onTapGesture(perform: onTap)
            .onAppear {
                startDancing()
            }
    }
    
    private func startDancing() {
        // Create unique timing for each emoji based on position to avoid synchronized movement
        let uniqueDelay = Double((Int(basePosition.x) + Int(basePosition.y)) % 100) / 100.0
        
        // Small circular/figure-8 movement
        withAnimation(
            .easeInOut(duration: Double.random(in: 1.0...2.0) * danceSpeedScale)
            .repeatForever(autoreverses: true)
            .delay(uniqueDelay)
        ) {
            danceOffset = CGSize(
                width: Double.random(in: -8...8),
                height: Double.random(in: -8...8)
            )
        }
        
        // Subtle rotation
        withAnimation(
            .easeInOut(duration: Double.random(in: 1.5...2.5) * danceSpeedScale)
            .repeatForever(autoreverses: true)
            .delay(uniqueDelay * 0.7)
        ) {
            rotationAngle = Double.random(in: -5...5)
        }
        
        // Gentle scaling
        withAnimation(
            .easeInOut(duration: Double.random(in: 1.25...1.75) * danceSpeedScale)
            .repeatForever(autoreverses: true)
            .delay(uniqueDelay * 1.3)
        ) {
            scale = Double.random(in: 0.95...1.05)
        }
    }
}