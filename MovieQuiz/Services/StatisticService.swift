//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 04.11.2024.
//

import Foundation

// Класс Сервис статистики
final class StatisticService: StatisticServiceProtocol {
    // Переменная для сокращения путей UserDefaults при объявлении ключей
    private let storage: UserDefaults = .standard
    // Перечисление для контроля типов UserDefaults
    private enum Keys: String {
        case totalAccuracy
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswersCount
    }
    // Переменная для количества корректных ответов
    var correctAnswersCount: Int {
        get {
            storage.integer(forKey: Keys.correctAnswersCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswersCount.rawValue)
        }
    }
    // Переменная для средней величины
    var totalAccuracy: Double {
        get {
            let correctAnswersCount = storage.integer(forKey: Keys.correctAnswersCount.rawValue)
            let gamesCount = self.gamesCount
            guard gamesCount > 0 else { return 0.0 }
            let totalQuestions = gamesCount * 10
            return (Double(correctAnswersCount) / Double(totalQuestions)) * 100
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    // Переменная для хранения кол-ва сыгранных игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue,forKey: Keys.gamesCount.rawValue)
        }
    }
    // Переменная хранения результатов лучшей игры
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    // Метод для сохранения результатов викторины, выбора рекорда и обновления статистики
    func store(correct count: Int, total amount: Int) {
        // Обновляем количество сыгранных игр
        gamesCount += 1
        // Обновляем общее количество правильных ответов
        correctAnswersCount += count
        // Проверяем, является ли текущая игра лучшей
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isBetterThan(bestGame) {
            bestGame = currentGameResult
        }
        // Обновляем общую точность
        let totalQuestions = gamesCount * 10
        totalAccuracy = (Double(correctAnswersCount) / Double(totalQuestions)) * 100
    }
}
