import UIKit

final class MovieQuizViewController: UIViewController {
    
    // Делаем статус-бар белым как в макете
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // Переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // Структура для Модели просмотра
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    // Структура для состояния "Вопрос показан"
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    // Структура для состояния "Результат квиза"
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    // Структура для вопроса
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    // Массив данных для вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",    text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",  text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill",        text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers",     text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool",         text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old",              text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla",            text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium",         text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    //Метод, который обрабатывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        // Отключаем кнопки на время ожидания
        buttonNo.isEnabled = false
        buttonYes.isEnabled = false
        
        // Меняем настройки контура на выделенные
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.masksToBounds = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    //Обработчик нажатия кнопки Да
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: true==questions[currentQuestionIndex].correctAnswer)
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    //Обработчик нажатия кнопки Нет
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: false==questions[currentQuestionIndex].correctAnswer)
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    // Метод конвертации, возвращает модель просмотра
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // Метод вывода на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Метод показывающий следующий вопрос или результы
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
        //Возвращаем настройки контура в дефолтные
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        // Включаем кнопки посе ожидания
        buttonNo.isEnabled = true
        buttonYes.isEnabled = true
    }
    
    // Метод показывает результаты
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentQuestionIndex = 0
        correctAnswers = 0
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
}
