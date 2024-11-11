//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 12.11.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    // Переменная с номером текущего вопроса
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Методо конвертации модели фильма для отображения
    internal func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
         didAnswer(isYes: true)
     }
     
     func noButtonClicked() {
         didAnswer(isYes: false)
     }
     
     private func didAnswer(isYes: Bool) {
         guard let currentQuestion = currentQuestion else {
             return
         }
         
         let givenAnswer = isYes
         
         viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
     }
    
    //Обработчик нажатия кнопки Да

    /*
    func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: true==currentQuestion.correctAnswer)
        
        show(quiz: presenter.convert(model: currentQuestion))
    }
    */
    
    /*
    //Обработчик нажатия кнопки Нет
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: false==currentQuestion.correctAnswer)
        show(quiz: presenter.convert(model: currentQuestion))
    }
     */
}

