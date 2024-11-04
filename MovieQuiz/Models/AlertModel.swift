//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitriy Chicherin on 03.11.2024.
//

import UIKit

// Структура для передачи данных для отображения в alert
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
