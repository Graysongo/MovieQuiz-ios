//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 13.11.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func defaultImageBorder()
    
    func showNetworkError(message: String)
}

