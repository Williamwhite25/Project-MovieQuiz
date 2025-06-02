//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by William White on 01.06.2025.
//

// QuestionFactoryDelegate.swift

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
