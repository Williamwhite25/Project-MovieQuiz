//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by William White on 06.06.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var totalAccuracy: Double { get }

    func store(correct count: Int, total amount: Int)
}
