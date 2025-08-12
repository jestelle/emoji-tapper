package com.emojitapper.models

enum class GameMode(val displayName: String, val description: String) {
    CLASSIC("Classic", "Tap emojis to score points and earn time"),
    PENGUIN_BALL("Penguin Ball", "Find the penguin among many emojis in 5 rounds");

    companion object {
        val allCases = values().toList()
    }
}

interface GameModeEngine {
    val gameMode: GameMode
    val score: Int
    val isGameActive: Boolean
    val currentEmojis: List<GameEmoji>
    val gameStateText: String
    val highScore: Int
    val timeRemainingForProgress: Double
    val totalTimeForProgress: Double
    
    var onEmojisChanged: (() -> Unit)?
    var onGameEnded: (() -> Unit)?
    
    fun startGame()
    fun endGame()
    fun emojiTapped(emoji: GameEmoji)
    fun proceedToNextRound()
    fun pauseTimers()
    fun resumeTimers()
    fun resetHighScore()
}