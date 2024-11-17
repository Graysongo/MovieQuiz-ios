//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 10.11.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
