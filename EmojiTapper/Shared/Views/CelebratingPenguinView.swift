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
        GeometryReader { geometry in
            Text(penguin.emoji)
                .font(.system(size: fontSize))
                .scaleEffect(isGrown ? 1.25 : 1.0, anchor: .center)
                .position(penguin.position)
                .animation(.easeInOut(duration: 0.3), value: isGrown)
        }
        .onAppear {
            isGrown = true
        }
    }
}