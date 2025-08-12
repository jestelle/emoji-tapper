package com.emojitapper.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import com.emojitapper.game.GameState
import com.emojitapper.ui.components.GameEndDialog
import com.emojitapper.ui.screens.GameScreen
import com.emojitapper.ui.screens.MenuScreen

@Composable
fun EmojiTapperApp() {
    val context = LocalContext.current
    val gameState: GameState = viewModel { GameState(context) }
    
    // Initialize engine when game mode changes
    LaunchedEffect(gameState.selectedGameMode) {
        gameState.selectGameMode(gameState.selectedGameMode)
    }
    
    Scaffold(
        modifier = Modifier.fillMaxSize()
    ) { paddingValues ->
        when {
            gameState.isGameActive -> {
                gameState.currentEngine?.let { engine ->
                    GameScreen(
                        gameEngine = engine,
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(paddingValues)
                    )
                }
            }
            else -> {
                MenuScreen(
                    selectedGameMode = gameState.selectedGameMode,
                    onGameModeChanged = { gameState.selectGameMode(it) },
                    onStartGame = { gameState.startGame() },
                    highScore = gameState.currentEngine?.highScore ?: 0,
                    onResetHighScore = { gameState.currentEngine?.resetHighScore() },
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues)
                )
            }
        }
        
        // Game end dialog
        if (gameState.showGameEndDialog) {
            GameEndDialog(
                score = gameState.lastScore,
                highScore = gameState.currentEngine?.highScore ?: 0,
                isNewHighScore = gameState.isNewHighScore,
                onPlayAgain = { gameState.playAgain() },
                onBackToMenu = { gameState.dismissGameEndDialog() }
            )
        }
    }
}