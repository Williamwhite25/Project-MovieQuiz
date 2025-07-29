import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var statisticService: StatisticServiceProtocol!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter!
    private let moviesLoader = MoviesLoader()
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLable: UILabel!
    @IBOutlet private var counterLable: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        setupUI()
        setupServices()
        
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self, questions: [])
        
        showLoadingIndicator()
        questionFactory?.loadData()

        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - QuestionFactoryDelegate Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            showNetworkError(message: "Нет доступных вопросов.")
            return
        }
        currentQuestion = question
        show(quiz: convert(model: question))
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        textLable.font = UIFont(name: "YPDisplay-Bold", size: 23)
        counterLable.font = UIFont(name: "YPDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YPDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YPDisplay-Medium", size: 20)
        
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        activityIndicator.isHidden = true
    }
    
    private func setupServices() {
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - Private functions
    private func loadMoviesFromNetwork() {
        showLoadingIndicator()
        moviesLoader.loadMovies { [weak self] (result: Result<MostPopularMovies, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    self?.questionFactory = self?.createQuestionFactory(with: mostPopularMovies)
                    self?.questionFactory?.delegate = self
                    self?.didLoadDataFromServer()
                case .failure(let error):
                    self?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    private func createQuestionFactory(with movies: MostPopularMovies) -> QuestionFactoryProtocol {
        let questions = movies.items.map {
            QuizQuestion(
                image: $0.imageURL.absoluteString,
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: Double($0.rating) ?? 0 > 6
            )
        }
        return QuestionFactory(moviesLoader: moviesLoader, delegate: self, questions: questions)
    }
    
    internal func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    internal func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: "Не удалось загрузить данные: \(error.localizedDescription)")
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.loadMoviesFromNetwork()
        }
        alertPresenter.showAlert(with: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.YPGreen.cgColor : UIColor.YPRed.cgColor
        
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
            imageURL: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        loadImage(from: step.imageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        self.textLable.text = step.question
        self.counterLable.text = step.questionNumber

        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
    }
    
    private func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            displayQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
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
            self?.questionFactory?.requestNextQuestion()
        }))
        
        present(alert, animated: true)
    }
}
