//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 09.11.2024.
//

import Foundation

// Структура для загрузки данных
struct MoviesLoader: MoviesLoading {
  // MARK: - NetworkClient
  private let networkClient: NetworkRouting
  
  init(networkClient: NetworkRouting = NetworkClient()) {
      self.networkClient = networkClient
  }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    // Запуск процесса загрузки
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
