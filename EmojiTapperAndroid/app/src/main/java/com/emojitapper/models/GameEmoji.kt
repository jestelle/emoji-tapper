package com.emojitapper.models

import androidx.compose.ui.geometry.Offset

data class GameEmoji(
    val id: String = java.util.UUID.randomUUID().toString(),
    val emoji: String,
    val type: EmojiType,
    val position: Offset = Offset.Zero,
    val zIndex: Int = 0
)

enum class EmojiType {
    NORMAL,
    SKULL,
    HOURGLASS,
    CHERRY
}

data class AnimatedEmoji(
    val id: String = java.util.UUID.randomUUID().toString(),
    val emoji: String,
    val startPosition: Offset,
    val endPosition: Offset,
    val isVisible: Boolean = true
)

data class AnimatedPositionChange(
    val id: String = java.util.UUID.randomUUID().toString(),
    val emoji: String,
    val position: Offset,
    val isVisible: Boolean = true
)