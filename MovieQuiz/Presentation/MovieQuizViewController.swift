import UIKit

class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // Делаем статус-бар белым как в макете
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
    
    // Метод преобразующий вопрос из модели QuizQuestion в модель представления для просмотра
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            // Создаем изображение model.image или если он не найдено используем пустой UIImage
            image: UIImage(named: model.image) ?? UIImage(),
            // Извлекаем текст вопроса из model.text
            question: model.text,
            // Формируем строку с номером текущего вопроса и общим количеством вопросов (например, "3/10").
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
            // Создаем презентор
            alertPresenter = AlertPresenter(delegate: self)
            // Обновление статистики с использованием statisticService
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            // Формируем тест алерта в соотвествии с шаблоном
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount) \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateFormatter.string(from: statisticService.bestGame.date))) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            // Формируем alertModel с заголовком, текстом и кнопкой
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: {
                    // Сбрасываем индекс и счетчик правильных ответов
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    // Запрашиваем следующий вопрос для начала новой игры
                    self.questionFactory.requestNextQuestion()
                }
            )
            // Передаем информацию в для отображения алерта.
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
        //  Создаем Фабрику вопросов
        let questionFactory = QuestionFactory()
        // Настраиваем делегата для Фабрики вопросов
        questionFactory.setup(delegate: self)
        // Присваиваем экземпляр фабрики вопросов свойству self.questionFactory для использования в других методах
        self.questionFactory = questionFactory
        // Запрашиваем первый вопрос
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    // Метод обеспечивает плавный переход к следующему вопросу и обновляет интерфейс для отображения этого вопроса.
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // Проверяем предоставила ли фабрика вопрос, если да сохраняем его в currentQuestion
        guard let question = question else {
            return
        }
        currentQuestion = question
        // Преобразуем вопрос в ViewModel для отображения
        let viewModel = convert(model: question)
        // Обновляем интерфейс в главном потоке через show(quiz: ) чтобы отобразить вопрос
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // Показ алерта
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
