//
//  HighScoreResetView.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import SwiftUI

struct HighScoreResetView: View {
    let highScore: Int
    let onReset: () -> Void
    let font: Font
    let color: Color
    let format: String // e.g., "High: %d" or "High Score: %d"
    
    @State private var tapCount = 0
    @State private var holdProgress: Double = 0.0
    @State private var opacity: Double = 1.0
    @State private var showResetConfirmation = false
    @State private var longPressTimer: Timer?
    @State private var tapResetTimer: Timer?
    
    var body: some View {
        Text(highScore > 0 ? String(format: format, highScore) : " ")
            .font(font)
            .foregroundColor(color)
            .opacity(highScore > 0 ? opacity : 0.0)
            .onTapGesture {
                handleTap()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        // Start long press on first change event
                        if longPressTimer == nil {
                            startLongPress()
                        }
                    }
                    .onEnded { _ in
                        cancelLongPress()
                    }
            )
            .alert("Reset High Score?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {
                    resetState()
                }
                Button("Reset", role: .destructive) {
                    onReset()
                    resetState()
                }
            } message: {
                Text("Are you sure you want to clear your high score of \(highScore)?")
            }
    }
    
    private func handleTap() {
        guard highScore > 0 else { return }
        
        print("DEBUG: Tap detected! Count will be: \(tapCount + 1)")
        
        // Cancel any ongoing long press but preserve tap count
        longPressTimer?.invalidate()
        longPressTimer = nil
        holdProgress = 0.0
        
        tapCount += 1
        
        // Reset tap count after 2 seconds of no tapping
        tapResetTimer?.invalidate()
        tapResetTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.resetTapCount()
        }
        
        // Start reducing opacity immediately with each tap
        let fadeProgress = Double(tapCount) / 20.0 // 0.0 to 1.0 over taps 1-20
        opacity = max(0.0, 1.0 - fadeProgress)
        
        print("DEBUG: Tap \(tapCount), opacity now: \(opacity)")
        
        // After 20 taps, show confirmation
        if tapCount >= 20 {
            print("DEBUG: 20 taps reached, showing confirmation")
            showResetConfirmation = true
            tapResetTimer?.invalidate()
        }
    }
    
    private func startLongPress() {
        guard highScore > 0 else { return }
        
        // Don't start long press if we're in the middle of a tap sequence
        if tapCount > 0 {
            return
        }
        
        // Cancel any ongoing tap sequence
        resetTapCount()
        
        holdProgress = 0.0
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.holdProgress += 0.1 / 5.0 // Increment over 5 seconds (0.1s intervals)
            
            // Start fading immediately and continue over full 5 seconds
            self.opacity = max(0.0, 1.0 - self.holdProgress)
            
            // Show confirmation after 5 seconds
            if self.holdProgress >= 1.0 {
                self.longPressTimer?.invalidate()
                self.showResetConfirmation = true
            }
        }
    }
    
    private func cancelLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        holdProgress = 0.0
        
        // Only reset opacity if we're not in a tap sequence
        if tapCount == 0 {
            opacity = 1.0
        }
    }
    
    private func resetTapCount() {
        tapCount = 0
        tapResetTimer?.invalidate()
        tapResetTimer = nil
        
        // Reset opacity back to full without animation to prevent conflicts
        opacity = 1.0
    }
    
    private func resetState() {
        tapCount = 0
        holdProgress = 0.0
        longPressTimer?.invalidate()
        longPressTimer = nil
        tapResetTimer?.invalidate()
        tapResetTimer = nil
        
        // Reset opacity back to full without animation
        opacity = 1.0
    }
}