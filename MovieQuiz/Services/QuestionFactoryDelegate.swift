//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 03.11.2024.
//

import Foundation

protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
