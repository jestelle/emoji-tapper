package com.emojitapper

import android.content.Context
import android.content.SharedPreferences
import com.emojitapper.game.ClassicGameEngine
import com.emojitapper.models.EmojiType
import com.emojitapper.models.GameEmoji
import org.junit.Before
import org.junit.Test
import org.junit.Assert.*
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations

class GameEngineTest {

    @Mock
    private lateinit var mockContext: Context

    @Mock
    private lateinit var mockSharedPreferences: SharedPreferences

    @Mock
    private lateinit var mockEditor: SharedPreferences.Editor

    private lateinit var gameEngine: ClassicGameEngine

    @Before
    fun setup() {
        MockitoAnnotations.openMocks(this)
        
        `when`(mockContext.getSharedPreferences("EmojiTapperPrefs", Context.MODE_PRIVATE))
            .thenReturn(mockSharedPreferences)
        `when`(mockSharedPreferences.edit()).thenReturn(mockEditor)
        `when`(mockEditor.putInt(anyString(), anyInt())).thenReturn(mockEditor)
        `when`(mockSharedPreferences.getInt("EmojiTapperClassicHighScore", 0)).thenReturn(0)
        
        gameEngine = ClassicGameEngine(mockContext)
    }

    @Test
    fun testInitialState() {
        assertFalse("Game should not be active initially", gameEngine.isGameActive)
        assertEquals("Initial score should be 0", 0, gameEngine.score)
        assertTrue("No emojis should be present initially", gameEngine.currentEmojis.isEmpty())
    }

    @Test
    fun testStartGame() {
        gameEngine.startGame()
        
        assertTrue("Game should be active after starting", gameEngine.isGameActive)
        assertEquals("Score should be 0 at start", 0, gameEngine.score)
        assertTrue("Emojis should be generated", gameEngine.currentEmojis.isNotEmpty())
    }

    @Test
    fun testNormalEmojiTap() {
        gameEngine.startGame()
        val initialScore = gameEngine.score
        val normalEmoji = GameEmoji(
            emoji = "😀",
            type = EmojiType.NORMAL
        )
        
        gameEngine.emojiTapped(normalEmoji)
        
        assertTrue("Score should increase", gameEngine.score > initialScore)
    }

    @Test
    fun testSkullEmojiEndsGame() {
        gameEngine.startGame()
        val skullEmoji = GameEmoji(
            emoji = "💀",
            type = EmojiType.SKULL
        )
        
        gameEngine.emojiTapped(skullEmoji)
        
        assertFalse("Game should end when skull is tapped", gameEngine.isGameActive)
    }

    @Test
    fun testCherryEmojiAddsPoints() {
        gameEngine.startGame()
        val initialScore = gameEngine.score
        val cherryEmoji = GameEmoji(
            emoji = "🍒",
            type = EmojiType.CHERRY
        )
        
        gameEngine.emojiTapped(cherryEmoji)
        
        assertEquals("Cherry should add 2 points", initialScore + 2, gameEngine.score)
    }
}