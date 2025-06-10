

import UIKit
import Foundation


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var statisticService: StatisticServiceProtocol!
    
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLable: UILabel!
    @IBOutlet private var counterLable: UILabel!
    
    
    
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
   
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLable.font = UIFont(name: "YPDisplay-Bold", size: 23)
        counterLable.font = UIFont(name: "YPDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YPDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YPDisplay-Medium", size: 20)
        
        statisticService = StatisticServiceImplementation()
        
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        questionFactory = QuestionFactory()
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - Private functions
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLable.text = step.question
        counterLable.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {            displayQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    
    private func displayQuizResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: statisticService.bestGame.date)
        
        let currentGameResult = "Ваш результат: \(correctAnswers) из \(questionsAmount)"
        let totalGamesCount = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let bestGameResult = "Рекорд: \(statisticService.bestGame.correct) из \(statisticService.bestGame.total) (\(formattedDate))"
        let averageAccuracy = String(format: "Средняя точность: %.2f%%", statisticService.totalAccuracy)
        let alertMessage = [currentGameResult, totalGamesCount, bestGameResult, averageAccuracy].joined(separator: "\n")
        
        
        let alert = UIAlertController(title: "Этот раунд окончен!", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Начать заново", style: .default, handler: { [weak self] _ in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory.requestNextQuestion()
            }))
        
        present(alert, animated: true)
    }
}

