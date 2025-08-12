package com.emojitapper.game

import android.content.Context
import androidx.compose.runtime.*
import androidx.lifecycle.ViewModel
import com.emojitapper.models.GameMode
import com.emojitapper.models.GameModeEngine

class GameState(private val context: Context) : ViewModel() {
    var selectedGameMode by mutableStateOf(GameMode.CLASSIC)
        private set
    
    var isGameActive by mutableStateOf(false)
        private set
    
    var showGameEndDialog by mutableStateOf(false)
        private set
    
    var lastScore by mutableIntStateOf(0)
        private set
    
    var isNewHighScore by mutableStateOf(false)
        private set
    
    private var _currentEngine: GameModeEngine? = null
    val currentEngine: GameModeEngine?
        get() = _currentEngine
    
    fun selectGameMode(gameMode: GameMode) {
        if (!isGameActive) {
            selectedGameMode = gameMode
            _currentEngine = createEngine(gameMode)
        }
    }
    
    fun startGame() {
        _currentEngine?.let { engine ->
            isGameActive = true
            showGameEndDialog = false
            
            engine.onGameEnded = {
                isGameActive = false
                lastScore = engine.score
                isNewHighScore = engine.score == engine.highScore && engine.score > 0
                showGameEndDialog = true
            }
            
            engine.startGame()
        }
    }
    
    fun dismissGameEndDialog() {
        showGameEndDialog = false
    }
    
    fun playAgain() {
        showGameEndDialog = false
        startGame()
    }
    
    private fun createEngine(gameMode: GameMode): GameModeEngine {
        return when (gameMode) {
            GameMode.CLASSIC -> ClassicGameEngine(context)
            GameMode.PENGUIN_BALL -> ClassicGameEngine(context) // TODO: Implement PenguinBallEngine
        }
    }
    
    override fun onCleared() {
        super.onCleared()
        (_currentEngine as? ViewModel)?.onCleared()
    }
}