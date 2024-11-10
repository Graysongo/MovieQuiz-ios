//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 10.11.2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
