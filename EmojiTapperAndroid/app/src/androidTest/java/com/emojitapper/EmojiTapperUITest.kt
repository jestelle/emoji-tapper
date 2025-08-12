package com.emojitapper

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit4.runners.AndroidJUnit4
import com.emojitapper.ui.EmojiTapperApp
import com.emojitapper.ui.theme.EmojiTapperTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class EmojiTapperUITest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun appDisplaysMenuScreenInitially() {
        composeTestRule.setContent {
            EmojiTapperTheme {
                EmojiTapperApp()
            }
        }

        // Check that start game button is visible
        composeTestRule.onNodeWithText("Start Game").assertIsDisplayed()
        
        // Check that leaderboard button is visible  
        composeTestRule.onNodeWithText("🏆 Leaderboard").assertIsDisplayed()
        
        // Check that game mode options are visible
        composeTestRule.onNodeWithText("Classic").assertIsDisplayed()
        composeTestRule.onNodeWithText("Penguin Ball").assertIsDisplayed()
    }

    @Test
    fun canSelectDifferentGameModes() {
        composeTestRule.setContent {
            EmojiTapperTheme {
                EmojiTapperApp()
            }
        }

        // Select Classic mode
        composeTestRule.onNodeWithText("Classic").performClick()
        
        // Verify Classic is selected and description is shown
        composeTestRule.onNodeWithText("Tap emojis to score points and earn time").assertIsDisplayed()
        
        // Select Penguin Ball mode
        composeTestRule.onNodeWithText("Penguin Ball").performClick()
        
        // Verify Penguin Ball description is shown
        composeTestRule.onNodeWithText("Find the penguin among many emojis in 5 rounds").assertIsDisplayed()
    }

    @Test
    fun startGameButtonWorks() {
        composeTestRule.setContent {
            EmojiTapperTheme {
                EmojiTapperApp()
            }
        }

        // Click start game button
        composeTestRule.onNodeWithText("Start Game").performClick()
        
        // Verify we're now in game screen (score should be visible)
        composeTestRule.onNodeWithText("0").assertIsDisplayed()
        
        // Menu buttons should no longer be visible
        composeTestRule.onNodeWithText("Start Game").assertDoesNotExist()
    }
}