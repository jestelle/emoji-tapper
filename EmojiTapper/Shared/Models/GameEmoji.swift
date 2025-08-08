//
//  GameEmoji.swift
//  Shared
//
//  Created by Josh Estelle on 8/8/25.
//

import Foundation

enum EmojiType {
    case normal
    case skull          // 💀 - ends game immediately  
    case hourglass      // ⏳ - adds 5 seconds
    case cherry         // 🍒 - gives 2 extra points
}

struct GameEmoji: Identifiable {
    let id: UUID
    let emoji: String
    let type: EmojiType
    let zIndex: Int // Higher values render on top
    
    init(emoji: String, type: EmojiType, zIndex: Int) {
        self.id = UUID()
        self.emoji = emoji
        self.type = type
        self.zIndex = zIndex
    }
    
    // Manual initializer to preserve ID when updating z-index
    init(id: UUID, emoji: String, type: EmojiType, zIndex: Int) {
        self.id = id
        self.emoji = emoji
        self.type = type
        self.zIndex = zIndex
    }
}