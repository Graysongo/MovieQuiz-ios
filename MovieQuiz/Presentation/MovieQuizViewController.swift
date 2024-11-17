// Обновление 5.0 со всеми комментариями

import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // Метод подсветки краёв экрана и блокировки кнопок от повторного нажатия
    func highlightImageBorder(isCorrectAnswer: Bool) {
        buttonNo.isEnabled = false
        buttonYes.isEnabled = false
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.green.cgColor : UIColor.red.cgColor
        imageView.layer.masksToBounds = true
    }
    
    // Метод делающий индикатор загрузки видимым
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    // Метод делающий индикатор загрузки скрытым
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // Метод возврата настроек краёв экрана в дефолтное состояние и разблокировки кнопок
    func defaultImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        // Включаем кнопки после ожидания (мы отключали их после нажатия кнопки)
        buttonNo.isEnabled = true
        buttonYes.isEnabled = true
    }
    
    // MARK: - Properties
    
    // Презентор
    private var presenter: MovieQuizPresenter!
    // Переменная с Алертом
    var alertPresenter: AlertPresenter?
    // Делаем статус-бар белым
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // Структура для Модели просмотра
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var buttonYes: UIButton!
    @IBOutlet weak private var buttonNo: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter()
        // Инициализируем начальные значения индекса и кол-ва верных ответов
        presenter.resetQuestionIndex()
        showLoadingIndicator()
        
        /* код для очистки UserDefaults,для тестов
         if let appDomain = Bundle.main.bundleIdentifier {
         UserDefaults.standard.removePersistentDomain(forName: appDomain)
         UserDefaults.standard.synchronize()
         }
         */
    }
    
    // MARK: - Methods
    
    // Метод который в случае ошибки загрузки показывает алерт
    func showNetworkError(message: String) {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Метод отображает текущий вопрос викторины
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Метод для отображения алерта
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
}
