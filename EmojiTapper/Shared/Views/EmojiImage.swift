//
//  EmojiImage.swift
//  Shared
//
//  Created by Josh Estelle on 8/12/25.
//

import SwiftUI

struct EmojiImage: View {
    let emoji: GameEmoji
    
    var body: some View {
        Image(emoji.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

extension GameEmoji {
    var imageName: String {
        let code = emoji.unicodeScalars.first!.value
        return "emoji_u\(String(code, radix: 16))"
    }
}