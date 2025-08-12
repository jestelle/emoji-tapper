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
    
    init(emoji: String, type: EmojiType) {
        self.id = UUID()
        self.emoji = emoji
        self.type = type
    }
}