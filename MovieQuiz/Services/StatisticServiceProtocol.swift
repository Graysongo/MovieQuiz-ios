//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 04.11.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var correctAnswersCount: Int { get }
    var bestGame: GameResult { get }

    func store(correct count: Int, total amount: Int)
}
