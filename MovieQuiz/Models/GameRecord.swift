//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by William White on 08.06.2025.
//

import UIKit
import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
