//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by William White on 08.06.2025.
//

import Foundation

class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage = UserDefaults.standard

    private enum Keys: String {
        case totalCorrectAnswers
        case gamesCount
        case bestGame
    }

    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    private var totalCorrectAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    var totalAccuracy: Double {
        let totalQuestions = gamesCount * 10
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestions)) * 100
    }

    var bestGame: GameRecord {
        get {
            guard let data = storage.data(forKey: Keys.bestGame.rawValue),
                  let gameRecord = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return GameRecord(correct: 0, total: 0, date: Date())
            }
            return gameRecord
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                storage.set(encoded, forKey: Keys.bestGame.rawValue)
            }
        }
    }

    func store(correct count: Int, total amount: Int) {
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        gamesCount += 1
        totalCorrectAnswers += count

        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
