// Обновление 5.0 со всеми комментариями

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // Делаем статус-бар белым
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // Переменная DateFormatter для маскирования вывода даты
    let dateFormatter = DateFormatter()

    // Переменная со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    private let presenter = MovieQuizPresenter()
    // Переменная с фабрикой вопросов выдающей рандомный вопрос
    private var questionFactory: QuestionFactoryProtocol?
 
    // Переменная с номером текущего вопроса
    private var currentQuestion: QuizQuestion?
    // Переменная с Алертом
    private var alertPresenter: AlertPresenter?
    // Переменная с сервисом статистики
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // Структура для Модели просмотра
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var buttonYes: UIButton!
    @IBOutlet weak private var buttonNo: UIButton!
    

    
    // Метод который в случае ошибки загрузки показывает алерт
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(with: alertModel)
    }
    
    // Метод отображает текущий вопрос викторины
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //Метод отображает верно ли нажата кнопка и меняет контур imageView соответствующе
    func showAnswerResult(isCorrect: Bool) {
        // Увеличиваем счетчик верных ответов если кнопка нажата верно
        if isCorrect {
            correctAnswers += 1
        }
        // Отключаем кнопки на время подсветки контура
        buttonNo.isEnabled = false
        buttonYes.isEnabled = false
        // Меняем настройки контура на выделенные с подтверждением цветом
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.masksToBounds = true
        // Через паузу вызываем следующий вопрос или окно результатов
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // Метод отвечает за переход к следующему вопросу или отображение результата, если вопрос был последним
    private func showNextQuestionOrResults() {
        // Устанавливаем формат даты для алерта
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        // Проверяем достигли ли мы последнего вопроса
        if presenter.isLastQuestion() {
            alertPresenter = AlertPresenter(delegate: self)
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount) \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateFormatter.string(from: statisticService.bestGame.date))) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    // Сбрасываем индекс и счетчик правильных ответов
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    // Запрашиваем следующий вопрос для начала новой игры
                    self.questionFactory?.requestNextQuestion()
                }
            )
            alertPresenter?.showAlert(with: alertModel)
            // Если вопрос не последний, переходим к следующему вопросу
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
        //Возвращаем настройки контура в настройки по умолчанию (мы меняли рамку после нажатия кнопки)
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        // Включаем кнопки после ожидания (мы отключали их после нажатия кнопки)
        buttonNo.isEnabled = true
        buttonYes.isEnabled = true
    }
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        // Инициализируем начальные значения индекса и кол-ва верных ответов
        presenter.resetQuestionIndex()
        correctAnswers = 0
        
        /* код для очистки UserDefaults, на будущее для тестов
         if let appDomain = Bundle.main.bundleIdentifier {
         UserDefaults.standard.removePersistentDomain(forName: appDomain)
         UserDefaults.standard.synchronize()
         }
         */
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // Проверяем предоставила ли фабрика вопрос, если да сохраняем его в currentQuestion
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        // Обновляем интерфейс в главном потоке через show(quiz: ) чтобы отобразить вопрос
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // Метод делающий индикатор загрузки видимым
    private func showLoadingIndicator() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
    }
    
    // Метод делающий индикатор загрузки скрытым
    private func hideLoadingIndicator() {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
    }
    
    // Метод запуска викторины если данные загрузились
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    // Метод отображающий ошибку если данные для викторины не загрузились
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    // Метод для отображения алерта
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
