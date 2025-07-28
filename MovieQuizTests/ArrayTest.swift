//
//  MovieQuizTests1.swift
//  MovieQuizTests1
//
//  Created by William White on 18.07.2025.
//

import XCTest

@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueRange() throws {
        let array = [1, 2, 3, 4, 5]
        
        let value = array[safe:2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOfRange() throws {
        let array = [1, 1, 2, 3, 5]
           
           
           let value = array[safe: 20]
           
           
           XCTAssertNil(value)
    }
}
