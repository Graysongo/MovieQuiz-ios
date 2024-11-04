//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 02.11.2024.
//

import Foundation

// Фабрика вопросов - генерирует случайный ответ из массива вопросов
class QuestionFactory: QuestionFactoryProtocol {
    // Делегат для передачи сгенерированных вопросов в основной контроллер, который подписан на протокол
    weak var delegate: QuestionFactoryDelegate?
    // Метод чтобы назначить объект, который будет получать вопросы, сгенерированные фабрикой.
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    // Массив данных для вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",    text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",  text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill",        text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers",     text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool",         text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old",              text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla",            text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium",         text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    // Метод отвечающий за генерацию случайного вопроса из массива questions и передачу его делегату.
    func requestNextQuestion() {
        // Генерируем случайный индекс в диапазоне от 0 до (Кол-во вопросов)-1
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        // Извлекаем вопрос
        let question = questions[safe: index]
        // При успешном извлечении передаем делегату
        delegate?.didReceiveNextQuestion(question: question)
    }
}
