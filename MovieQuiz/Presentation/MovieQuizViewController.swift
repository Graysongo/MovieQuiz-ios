// Обновление 5.0 со всеми комментариями

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // Делаем статус-бар белым
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // Переменная DateFormatter для маскирования вывода даты
    let dateFormatter = DateFormatter()
    // Переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // Переменная со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    // Переменная с кол-вом вопросов в квизе
    private let questionsAmount: Int = 10
    // Переменная с фабрикой вопросов выдающей рандомный вопрос
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    // Переменная с номером текущего вопроса
    private var currentQuestion: QuizQuestion?
    // Переменная с Алертом
    private var alertPresenter: AlertPresenter?
    // Переменная с сервисом статистики
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // Структура для Модели просмотра
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // Метод отображает текущий вопрос викторины
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //Метод отображает верно ли нажата кнопка и меняет контур imageView соответствующе
    private func showAnswerResult(isCorrect: Bool) {
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
        // Проверяем достигли ли мы последнего вопроса
        if currentQuestionIndex == questionsAmount - 1 {
            alertPresenter = AlertPresenter(delegate: self)
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount) \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateFormatter.string(from: statisticService.bestGame.date))) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    // Сбрасываем индекс и счетчик правильных ответов
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    // Запрашиваем следующий вопрос для начала новой игры
                    self.questionFactory.requestNextQuestion()
                }
            )
            alertPresenter?.showAlert(with: alertModel)
            // Если вопрос не последний, переходим к следующему вопросу
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
        }
        //Возвращаем настройки контура в настройки по умолчанию (мы меняли рамку после нажатия кнопки)
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        // Включаем кнопки после ожидания (мы отключали их после нажатия кнопки)
        buttonNo.isEnabled = true
        buttonYes.isEnabled = true
    }
    
    //Обработчик нажатия кнопки Да
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: true==currentQuestion.correctAnswer)
        show(quiz: convert(model: currentQuestion))
    }
    
    //Обработчик нажатия кнопки Нет
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: false==currentQuestion.correctAnswer)
        show(quiz: convert(model: currentQuestion))
    }
    
    // Метод загрузки UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Инициализируем начальные значения индекса и кол-ва верных ответов
        currentQuestionIndex = 0
        correctAnswers = 0
        // Устанавливаем маску дата:время для вывода в алерте
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        // Запрашиваем первый вопрос
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // Проверяем предоставила ли фабрика вопрос, если да сохраняем его в currentQuestion
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        // Обновляем интерфейс в главном потоке через show(quiz: ) чтобы отобразить вопрос
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
