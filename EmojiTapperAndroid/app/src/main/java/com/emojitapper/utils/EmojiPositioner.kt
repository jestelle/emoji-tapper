package com.emojitapper.utils

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.IntSize
import com.emojitapper.models.GameEmoji
import kotlin.random.Random

class AndroidEmojiPositioner {
    fun positionEmojis(emojis: List<GameEmoji>, screenSize: IntSize): List<GameEmoji> {
        val emojiSize = 60 // Emoji font size in dp
        val margin = emojiSize / 2
        
        val availableWidth = screenSize.width - (margin * 2)
        val availableHeight = screenSize.height - (margin * 2)
        
        return emojis.map { emoji ->
            val x = Random.nextFloat() * availableWidth + margin
            val y = Random.nextFloat() * availableHeight + margin
            
            emoji.copy(position = Offset(x, y))
        }
    }
    
    fun isEmojiTapped(emoji: GameEmoji, tapPosition: Offset, emojiSize: Float = 60f): Boolean {
        val emojiCenter = emoji.position
        val distance = kotlin.math.sqrt(
            (tapPosition.x - emojiCenter.x) * (tapPosition.x - emojiCenter.x) +
            (tapPosition.y - emojiCenter.y) * (tapPosition.y - emojiCenter.y)
        )
        
        return distance <= emojiSize / 2
    }
}