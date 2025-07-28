

import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        
        let viewControllerMock = MovieQuizViewControllerMock()
        
       
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
      
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
       
        let viewModel = sut.convert(model: question)
        
        
        XCTAssertNotNil(viewModel.image, "Изображение должно быть не nil")
        XCTAssertEqual(viewModel.question, "Question Text", "Текст вопроса должен соответствовать")
        XCTAssertEqual(viewModel.questionNumber, "1/10", "Номер вопроса должен быть 1/10")

    }
}
  
