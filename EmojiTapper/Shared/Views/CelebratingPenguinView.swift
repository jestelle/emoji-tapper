//
//  CelebratingPenguinView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct CelebratingPenguinView: View {
    let penguin: PositionedGameEmoji
    @State private var isGrown = false
    
    var body: some View {
        EmojiImage(emoji: GameEmoji(emoji: penguin.emoji, type: .normal))
            .frame(width: 50, height: 50)
            .scaleEffect(isGrown ? 1.25 : 1.0, anchor: .center)
            .position(penguin.position)
            .animation(.easeInOut(duration: 0.3), value: isGrown)
            .onAppear {
                isGrown = true
            }
    }
}