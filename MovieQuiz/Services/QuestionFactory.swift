//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 02.11.2024.
//

import Foundation

// Фабрика вопросов - генерирует случайный ответ из массива вопросов
class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
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
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    /*
     
     
     func requestNextQuestion() -> QuizQuestion? {
         guard let index = (0..<questions.count).randomElement() else {
             return nil
         }
         return questions[safe: index]
     }
    subscript(index: Int) -> Int {
        get {
            // Возвращаем соответствующее значение
        }
        set(newValue) {
            // Устанавливаем подходящее значение
        }
    }
    */
}
