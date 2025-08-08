//
//  AnimatedEmojiView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct AnimatedEmojiView: View {
    let animatedEmoji: AnimatedEmoji
    let fontSize: CGFloat
    @State private var currentPosition: CGPoint
    @State private var isAnimating = false
    
    init(animatedEmoji: AnimatedEmoji, fontSize: CGFloat) {
        self.animatedEmoji = animatedEmoji
        self.fontSize = fontSize
        self._currentPosition = State(initialValue: animatedEmoji.startPosition)
    }
    
    var body: some View {
        Text(animatedEmoji.emoji)
            .font(.system(size: fontSize))
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