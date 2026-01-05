import UIKit

// MARK: - OnboardingPageViewController
final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Private Properties
    private let imageName: String
    private let titleName: String
    private let firstButton: Bool
    var onStartTap: (() -> Void)?

    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButtonTap = UIButton(type: .system)
    
    // MARK: - Initialization
    init(imageName: String, title: String, firstButton: Bool) {
        self.imageName = imageName
        self.titleName = title
        self.firstButton = firstButton
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка фонового изображения
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

        // Настройка заголовка
        titleLabel.text = titleName
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .ypBlack
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Настройка кнопки действия
        actionButtonTap.setTitle(NSLocalizedString("onboarding.button.start", comment: ""), for: .normal)
        actionButtonTap.backgroundColor = .ypBlack
        actionButtonTap.setTitleColor(.ypWhite, for: .normal)
        actionButtonTap.layer.cornerRadius = 16
        actionButtonTap.isHidden = !firstButton
        actionButtonTap.translatesAutoresizingMaskIntoConstraints = false
        actionButtonTap.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(actionButtonTap)

        // Установка constraints для всех элементов
        NSLayoutConstraint.activate([
            
            // Фоновое изображение
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Заголовок
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 66),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Кнопка
            actionButtonTap.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonTap.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButtonTap.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            actionButtonTap.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions
    @objc private func tap() {
        onStartTap?()
    }
}




