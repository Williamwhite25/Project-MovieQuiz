import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var alertPresenter: AlertPresenter!
    private let moviesLoader = MoviesLoader()
    private var presenter: MovieQuizPresenter!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLable: UILabel!
    @IBOutlet var counterLable: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - Setup Methods
    private func setupPresenter() {
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    private func setupUI() {
        imageView.layer.cornerRadius = 20
        yesButton.layer.cornerRadius = 15
        yesButton.layer.masksToBounds = true
        noButton.layer.cornerRadius = 15
        noButton.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        toggleButtons(isEnabled: false)
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        toggleButtons(isEnabled: false)
        presenter.noButtonClicked()
    }
    
    private func toggleButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // MARK: - UI Updates
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.YPGreen.cgColor : UIColor.YPRed.cgColor
    }
    
    func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func show(quiz: QuizStepViewModel) {
        imageView.image = quiz.image
        textLable.text = quiz.question
        counterLable.text = quiz.questionNumber
        toggleButtons(isEnabled: true)
    }
    
    func show(quiz: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        let alert = UIAlertController(title: quiz.title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: quiz.buttonText, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presenter.restartGame()
        })
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alertPresenter.showAlert(with: model)
    }

    // MARK: - Helpers
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
}
