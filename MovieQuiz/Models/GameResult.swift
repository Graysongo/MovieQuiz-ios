//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 04.11.2024.
//

import Foundation

// Структура для хранения результатов викторины
struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
