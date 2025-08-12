package com.emojitapper.models

interface GameLevel {
    val initialTime: Double
    val timeBonus: Double
    
    fun pointsForTapping(emoji: String): Int
}

class BasicLevel : GameLevel {
    override val initialTime: Double = 10.0
    override val timeBonus: Double = 0.1 // 10% time bonus
    
    override fun pointsForTapping(emoji: String): Int = 1
}