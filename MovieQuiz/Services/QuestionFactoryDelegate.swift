//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 03.11.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}
