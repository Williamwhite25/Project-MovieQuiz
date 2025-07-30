//
//  MovieQuizPresenter.swift
//  MovieQuiz2
//
//  Created by William White on 29.07.2025.
//
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Properties
    private let statisticService: StatisticService
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private(set) var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewControllerProtocol?) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            viewController?.showNetworkError(message: "Нет доступных вопросов.")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - User Actions
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Game Logic
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = isYes == currentQuestion.correctAnswer
        if isCorrect { correctAnswers += 1 }
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func proceedToNextQuestionOrResults() {
        resetImageBorder()
        if isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        return [
            "Ваш результат: \(correctAnswers)\\\(questionsAmount)",
            "Количество сыгранных квизов: \(statisticService.gamesCount)",
            "Рекорд: \(bestGame.correct)\\\(bestGame.total) (\(bestGame.date.dateTimeString))",
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        ].joined(separator: "\n")
    }
    
    // MARK: - Helpers
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func resetImageBorder() {
        viewController?.resetImageBorder()
    }
}
