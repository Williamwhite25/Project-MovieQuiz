//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by William White on 30.05.2025.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private var questions: [QuizQuestion] = []
    private var currentQuestionIndex: Int = 0
    private let moviesLoader: MoviesLoader
    
    init(moviesLoader: MoviesLoader, delegate: QuestionFactoryDelegate?,
         questions: [QuizQuestion]) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
        self.questions = questions
    }
    
    func requestNextQuestion() {
        guard !questions.isEmpty else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = questions[currentQuestionIndex]
        delegate?.didReceiveNextQuestion(question: question)
        currentQuestionIndex = (currentQuestionIndex + 1) % questions.count
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.isEmpty {
                        self.delegate?.didReceiveNextQuestion(question: nil)
                        return
                    }
                    self.questions = mostPopularMovies.items.map { movie in
                        let rating = Float(movie.rating) ?? 0
                        let text = "Рейтинг этого фильма больше, чем 7?"
                        let correctAnswer = rating > 7
                        return QuizQuestion(image: movie.resizedImageURL.absoluteString, text: text, correctAnswer: correctAnswer)
                    }
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
