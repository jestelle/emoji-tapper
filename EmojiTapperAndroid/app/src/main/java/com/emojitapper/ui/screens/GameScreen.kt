package com.emojitapper.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emojitapper.models.GameModeEngine
import com.emojitapper.utils.AndroidEmojiPositioner

@Composable
fun GameScreen(
    gameEngine: GameModeEngine,
    modifier: Modifier = Modifier
) {
    val configuration = LocalConfiguration.current
    val density = LocalDensity.current
    val textMeasurer = rememberTextMeasurer()
    val emojiPositioner = remember { AndroidEmojiPositioner() }
    
    // Convert screen dimensions to pixels
    val screenWidth = with(density) { configuration.screenWidthDp.dp.toPx().toInt() }
    val screenHeight = with(density) { configuration.screenHeightDp.dp.toPx().toInt() }
    val screenSize = IntSize(screenWidth, screenHeight)
    
    // Position emojis when they change
    val positionedEmojis by remember(gameEngine.currentEmojis) {
        derivedStateOf {
            emojiPositioner.positionEmojis(gameEngine.currentEmojis, screenSize)
        }
    }
    
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Game canvas with emojis
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    detectTapGestures { tapOffset ->
                        // Find tapped emoji
                        val tappedEmoji = positionedEmojis
                            .sortedByDescending { it.zIndex }
                            .find { emoji ->
                                emojiPositioner.isEmojiTapped(emoji, tapOffset, 60f)
                            }
                        
                        tappedEmoji?.let { gameEngine.emojiTapped(it) }
                    }
                }
        ) {
            // Draw emojis
            positionedEmojis
                .sortedBy { it.zIndex }
                .forEach { emoji ->
                    drawEmoji(
                        drawScope = this,
                        emoji = emoji.emoji,
                        position = emoji.position,
                        textMeasurer = textMeasurer,
                        fontSize = 60.sp
                    )
                }
        }
        
        // Game UI overlay
        Column(
            modifier = Modifier.fillMaxSize()
        ) {
            // Timer progress bar (for Classic mode)
            if (gameEngine.timeRemainingForProgress > 0) {
                val progress = (gameEngine.timeRemainingForProgress / gameEngine.totalTimeForProgress).coerceIn(0.0, 1.0)
                LinearProgressIndicator(
                    progress = { progress.toFloat() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                        .height(8.dp),
                    color = MaterialTheme.colorScheme.primary,
                )
            }
            
            Spacer(modifier = Modifier.weight(1f))
            
            // Score display
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Bottom
            ) {
                Text(
                    text = gameEngine.score.toString(),
                    style = MaterialTheme.typography.headlineLarge,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                )
                
                Text(
                    text = gameEngine.gameStateText,
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f)
                )
            }
        }
    }
}

private fun drawEmoji(
    drawScope: DrawScope,
    emoji: String,
    position: Offset,
    textMeasurer: androidx.compose.ui.text.TextMeasurer,
    fontSize: androidx.compose.ui.unit.TextUnit
) {
    val textStyle = TextStyle(
        fontSize = fontSize,
        fontWeight = FontWeight.Normal
    )
    
    val textLayoutResult = textMeasurer.measure(emoji, textStyle)
    val textSize = textLayoutResult.size
    
    drawScope.drawText(
        textLayoutResult,
        topLeft = Offset(
            position.x - textSize.width / 2f,
            position.y - textSize.height / 2f
        )
    )
}