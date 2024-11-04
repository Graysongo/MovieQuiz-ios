//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 03.11.2024.
//

import UIKit

class AlertPresenter {
    // Делегат для передачи окна алерта
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    // Метод показа alert
    func showAlert(with model: AlertModel) {
        // Создаем UIAlertController
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        // Добавляем кнопку OK с выполнением замыкания при нажатии
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        // Используем делегат для показа алерта
        delegate?.presentAlert(alert)
    }
}


