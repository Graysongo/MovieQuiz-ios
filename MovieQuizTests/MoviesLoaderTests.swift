//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by dmitry.chicherin on 10.11.2024.
//

import XCTest // не забывайте импортировать фреймворк для тестирования
@testable import MovieQuiz // импортируем приложение для тестирования

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        // говорим, что не хотим эмулировать ошибку
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                // давайте проверим, что пришло, например, два фильма — ведь в тестовых данных их всего два
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        
        // When
        
        // Then
    }
}
