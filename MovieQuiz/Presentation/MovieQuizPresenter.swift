//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by dmitry.chicherin on 12.11.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
  
    // MARK: - Properties
    
    private let statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    // Переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    // Переменная DateFormatter для маскирования вывода даты
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter
    }()
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Initializer
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Methods
    
    // Метод получения следующего вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // Проверяем предоставила ли фабрика вопрос, если да сохраняем его в currentQuestion
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        // Обновляем интерфейс в главном потоке через show(quiz: ) чтобы отобразить вопрос
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // Метод проверки последний ли вопрос
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // Метод сброса текущего индекса вопроса
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    // Метод переключения к следующему вопросу
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Метод сброса настроек для следующей игры
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // Метод конвертации модели фильма для отображения
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        guard currentQuestion != nil else {
            print("Ошибка: currentQuestion равен nil при нажатии кнопки.")
            return
        }
        didAnswer(isYes: false)
    }
    
    func makeResultsMessage() -> String {
           statisticService.store(correct: correctAnswers, total: questionsAmount)
           let resultMessage = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateFormatter.string(from: statisticService.bestGame.date)))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        return resultMessage
       }
 
    //Метод отображегния верно ли нажата кнопка и меняет контур imageView соответствующе
    func showAnswerResult(isCorrect: Bool) {
        //presenter.didAnswer(isYes: isCorrect)
        if (isCorrect) {  correctAnswers += 1 }
        // Отключаем кнопки и меняем настройки контура
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        // Через паузу вызываем следующий вопрос или окно результатов
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
            viewController?.defaultImageBorder()
        }
    }
    
    // Метод определения верности ответа
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            print("Ошибка: currentQuestion равен nil в didAnswer.")
            return
        }
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // Метод проверки загружены ли данные
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // Метод при ошибке загрузки данных
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    // Метод отвечает за переход к следующему вопросу или отображение результата, если вопрос был последним
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
                viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

}

