//
//  TopMovies.swift
//  MovieQuiz
//
//  Created by William White on 11.06.2025.
//

import Foundation

struct Movie: Codable {
    let id: String
    let rank: String
    let title: String
    let fullTitle: String
    let year: String
    let image: String
    let crew: String
    let imDbRating: String
    let imDbRatingCount: String
}

struct Top: Decodable {
    let items: [Movie]
}

func loadMovies() {
    guard let url = Bundle.main.url(forResource: "top250MoviesIMDB", withExtension: "json") else {
        print("Файл не найден")
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let topMovies = try decoder.decode(Top.self, from: data)
        
        for movie in topMovies.items {
            print("Фильм: \(movie.title), Рейтинг: \(movie.imDbRating)")
        }
    } catch {
        print("Ошибка парсинга JSON: \(error)")
    }
}



