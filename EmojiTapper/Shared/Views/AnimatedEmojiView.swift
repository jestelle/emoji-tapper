//
//  AnimatedEmojiView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct AnimatedEmojiView: View {
    let animatedEmoji: AnimatedEmoji
    @State private var currentPosition: CGPoint
    @State private var isAnimating = false
    
    init(animatedEmoji: AnimatedEmoji) {
        self.animatedEmoji = animatedEmoji
        self._currentPosition = State(initialValue: animatedEmoji.startPosition)
    }
    
    var body: some View {
        EmojiImage(emoji: GameEmoji(emoji: animatedEmoji.emoji, type: .normal))
            .frame(width: 50, height: 50)
            .position(currentPosition)
            .scaleEffect(isAnimating ? 0.3 : 1.0) // Shrink as it flies away
            .opacity(isAnimating ? 0.0 : 1.0) // Fade out
            .onAppear {
                withAnimation(.easeOut(duration: animatedEmoji.duration)) {
                    currentPosition = animatedEmoji.endPosition
                    isAnimating = true
                }
            }
    }
}