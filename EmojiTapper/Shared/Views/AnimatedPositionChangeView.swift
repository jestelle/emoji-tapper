//
//  AnimatedPositionChangeView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct AnimatedPositionChangeView: View {
    let animatedChange: AnimatedPositionChange
    let fontSize: CGFloat
    let onComplete: () -> Void
    
    @State private var progress: Double = 0.0
    
    var currentPosition: CGPoint {
        // Calculate position along cubic bezier curve
        let t = progress
        let t2 = t * t
        let t3 = t2 * t
        let mt = 1.0 - t
        let mt2 = mt * mt
        let mt3 = mt2 * mt
        
        let x = mt3 * animatedChange.startPosition.x +
                3 * mt2 * t * animatedChange.controlPoint1.x +
                3 * mt * t2 * animatedChange.controlPoint2.x +
                t3 * animatedChange.endPosition.x
        
        let y = mt3 * animatedChange.startPosition.y +
                3 * mt2 * t * animatedChange.controlPoint1.y +
                3 * mt * t2 * animatedChange.controlPoint2.y +
                t3 * animatedChange.endPosition.y
        
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        Text(animatedChange.emoji)
            .font(.system(size: fontSize))
            .position(currentPosition)
            .zIndex(Double(animatedChange.zIndex))
            .onAppear {
                withAnimation(.easeInOut(duration: animatedChange.duration)) {
                    progress = 1.0
                }
                
                // Call completion callback after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + animatedChange.duration) {
                    onComplete()
                }
            }
    }
}