//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by William White on 01.06.2025.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
