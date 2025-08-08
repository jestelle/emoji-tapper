//
//  CelebratingPenguinView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct CelebratingPenguinView: View {
    let penguin: PositionedGameEmoji
    let fontSize: CGFloat
    @State private var isGrown = false
    
    var body: some View {
        Text(penguin.emoji)
            .font(.system(size: fontSize))
            .position(penguin.position)
            .scaleEffect(isGrown ? 1.25 : 1.0) // Grow by 25%
            .animation(.easeInOut(duration: 0.3), value: isGrown)
            .onAppear {
                isGrown = true
            }
    }
}