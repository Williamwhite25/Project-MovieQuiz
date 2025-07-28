

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var lastQuizStep: QuizStepViewModel?
    var lastQuizResult: QuizResultsViewModel?
    var lastNetworkErrorMessage: String?
    var highlightedCorrectAnswer: Bool?

    func show(quiz step: QuizStepViewModel) {
        lastQuizStep = step
    }

    func show(quiz result: QuizResultsViewModel) {
        lastQuizResult = result
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightedCorrectAnswer = isCorrectAnswer
    }

    func showLoadingIndicator() {}

    func hideLoadingIndicator() {}

    func showNetworkError(message: String) {
        lastNetworkErrorMessage = message
    }
}
