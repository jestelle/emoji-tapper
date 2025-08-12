package com.emojitapper.game

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emojitapper.models.*
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.min

class ClassicGameEngine(private val context: Context) : ViewModel(), GameModeEngine {
    override val gameMode = GameMode.CLASSIC
    
    override var score by mutableIntStateOf(0)
    override var isGameActive by mutableStateOf(false)
    override val currentEmojis = mutableStateListOf<GameEmoji>()
    
    private var timeRemaining by mutableDoubleStateOf(10.0)
    override val timeRemainingForProgress: Double get() = timeRemaining
    override val totalTimeForProgress: Double get() = currentLevel.initialTime
    
    override val gameStateText: String
        get() = String.format("%.1f", timeRemaining)
    
    override var highScore by mutableIntStateOf(0)
        private set
    
    override var onEmojisChanged: (() -> Unit)? = null
    override var onGameEnded: (() -> Unit)? = null
    
    private var currentLevel: GameLevel = BasicLevel()
    private var gameTimer: Job? = null
    
    private val normalEmojis = listOf(
        "😀", "😊", "😂", "🥰", "😎", "🤔", "😮", "😋", "🙂", 
        "😆", "😍", "🤗", "😴", "🤯", "😇"
    )
    private val specialEmojis = listOf("💀", "⏳", "🍒")
    
    private val prefs: SharedPreferences = context.getSharedPreferences(
        "EmojiTapperPrefs", Context.MODE_PRIVATE
    )
    
    init {
        loadHighScore()
    }
    
    private val maxEmojisOnScreen: Int
        get() {
            val elapsed = currentLevel.initialTime - timeRemaining
            return min(50, 1 + (elapsed / 2.0).toInt())
        }
    
    override fun startGame() {
        score = 0
        timeRemaining = currentLevel.initialTime
        isGameActive = true
        generateNewEmojis()
        startTimer()
    }
    
    override fun endGame() {
        isGameActive = false
        stopTimer()
        
        if (score > highScore) {
            highScore = score
            saveHighScore()
        }
        
        onGameEnded?.invoke()
    }
    
    override fun emojiTapped(emoji: GameEmoji) {
        if (!isGameActive) return
        
        when (emoji.type) {
            EmojiType.NORMAL -> {
                val points = currentLevel.pointsForTapping(emoji.emoji)
                score += points
                if (points > 0) {
                    timeRemaining += timeRemaining * currentLevel.timeBonus
                }
            }
            EmojiType.SKULL -> {
                endGame()
                return
            }
            EmojiType.HOURGLASS -> {
                timeRemaining += 1.0
            }
            EmojiType.CHERRY -> {
                score += 2
            }
        }
        
        generateNewEmojis()
        onEmojisChanged?.invoke()
    }
    
    override fun proceedToNextRound() {
        // Classic mode doesn't have rounds
    }
    
    override fun pauseTimers() {
        // Classic mode doesn't need timer pausing
    }
    
    override fun resumeTimers() {
        // Classic mode doesn't need timer resuming
    }
    
    override fun resetHighScore() {
        highScore = 0
        prefs.edit().putInt("EmojiTapperClassicHighScore", 0).apply()
    }
    
    private fun generateNewEmojis() {
        currentEmojis.clear()
        val targetCount = maxEmojisOnScreen
        
        var zIndex = 0
        
        // Always add at least one normal emoji
        val normalEmoji = normalEmojis.random()
        currentEmojis.add(
            GameEmoji(
                emoji = normalEmoji,
                type = EmojiType.NORMAL,
                zIndex = zIndex++
            )
        )
        
        // Fill remaining slots
        val remainingSlots = targetCount - 1
        repeat(remainingSlots) {
            val randomValue = kotlin.random.Random.nextDouble()
            
            when {
                randomValue < 0.4 -> {
                    // Add skull (40% chance)
                    currentEmojis.add(
                        GameEmoji(
                            emoji = "💀",
                            type = EmojiType.SKULL,
                            zIndex = zIndex++
                        )
                    )
                }
                randomValue < 0.5 -> {
                    // Add hourglass if we don't have one (10% chance)
                    val hasHourglass = currentEmojis.any { it.type == EmojiType.HOURGLASS }
                    if (!hasHourglass) {
                        currentEmojis.add(
                            GameEmoji(
                                emoji = "⏳",
                                type = EmojiType.HOURGLASS,
                                zIndex = zIndex++
                            )
                        )
                    } else {
                        // Add normal emoji instead
                        currentEmojis.add(
                            GameEmoji(
                                emoji = normalEmojis.random(),
                                type = EmojiType.NORMAL,
                                zIndex = zIndex++
                            )
                        )
                    }
                }
                randomValue < 0.6 -> {
                    // Add cherry if we have less than 3 (10% chance)
                    val cherryCount = currentEmojis.count { it.type == EmojiType.CHERRY }
                    if (cherryCount < 3) {
                        currentEmojis.add(
                            GameEmoji(
                                emoji = "🍒",
                                type = EmojiType.CHERRY,
                                zIndex = zIndex++
                            )
                        )
                    } else {
                        // Add normal emoji instead
                        currentEmojis.add(
                            GameEmoji(
                                emoji = normalEmojis.random(),
                                type = EmojiType.NORMAL,
                                zIndex = zIndex++
                            )
                        )
                    }
                }
                else -> {
                    // Add normal emoji (40% chance)
                    currentEmojis.add(
                        GameEmoji(
                            emoji = normalEmojis.random(),
                            type = EmojiType.NORMAL,
                            zIndex = zIndex++
                        )
                    )
                }
            }
        }
    }
    
    private fun startTimer() {
        gameTimer = viewModelScope.launch {
            while (isGameActive && timeRemaining > 0) {
                delay(100) // 0.1 second intervals
                timeRemaining -= 0.1
                if (timeRemaining <= 0) {
                    endGame()
                }
            }
        }
    }
    
    private fun stopTimer() {
        gameTimer?.cancel()
        gameTimer = null
    }
    
    private fun saveHighScore() {
        prefs.edit().putInt("EmojiTapperClassicHighScore", highScore).apply()
    }
    
    private fun loadHighScore() {
        highScore = prefs.getInt("EmojiTapperClassicHighScore", 0)
    }
    
    override fun onCleared() {
        super.onCleared()
        stopTimer()
    }
}