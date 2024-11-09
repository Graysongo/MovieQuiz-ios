//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 09.11.2024.
//

import Foundation

/// Отвечает за загрузку данных по URL
struct NetworkClient {
    // Перечисление с типами ошибок
    private enum NetworkError: Error {
        case codeError
    }
    // Метод отвечачющий за выполнение сетевого запроса
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
