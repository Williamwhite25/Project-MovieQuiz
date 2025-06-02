//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by William White on 01.06.2025.
//

// QuestionFactoryProtocol.swift

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func setup(delegate: QuestionFactoryDelegate)
    func requestNextQuestion()
}
