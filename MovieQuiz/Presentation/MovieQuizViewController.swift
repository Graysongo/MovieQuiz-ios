import UIKit

final class MovieQuizViewController: UIViewController {
    
    private var currentQuestionIndex = 0            // Переменная с индексом текущего вопроса, начальное значение 0
    private var correctAnswers = 0                  // Переменная со счётчиком правильных ответов, начальное значение закономерно 0
    
    struct ViewModel {                              // Структура для Модели просмотра
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizStepViewModel {                      // Структура для состояния "Вопрос показан"
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizResultsViewModel {                   // Структура для состояния "Результат квиза"
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizQuestion {                           // Структура для вопроса
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private let questions: [QuizQuestion] = [       // Массив данных для вопросов
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
    
    private func showAnswerResult(isCorrect: Bool) {    //Метод, который обрабатывает результат ответа
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.masksToBounds = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {    //Обработчик нажатия кнопки Да
        showAnswerResult(isCorrect: true==questions[currentQuestionIndex].correctAnswer)
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {     //Обработчик нажатия кнопки Нет
        showAnswerResult(isCorrect: false==questions[currentQuestionIndex].correctAnswer)
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {        // Метод конвертации, возвращает модель просмотра
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {   // Метод вывода на экран вопроса
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {          // Метод показывающий следующий вопрос или результы
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10" // 1
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    private func show(quiz result: QuizResultsViewModel) { // Метод показывает результаты
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
