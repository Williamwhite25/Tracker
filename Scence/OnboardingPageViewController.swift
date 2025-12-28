
import UIKit

final class OnboardingPageViewController: UIViewController {
    private let imageName: String
    private let titleName: String
    private let firstButton: Bool
    var onStartTap: (() -> Void)?

    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButtonTap = UIButton(type: .system)

    init(imageName: String, title: String, firstButton: Bool) {
        self.imageName = imageName
        self.titleName = title
        self.firstButton = firstButton
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

       
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

      
        titleLabel.text = titleName
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .ypBlack
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        
        actionButtonTap.setTitle("Вот это технологии!", for: .normal)
        actionButtonTap.backgroundColor = .ypBlack
        actionButtonTap.setTitleColor(.ypWhite, for: .normal)
        actionButtonTap.layer.cornerRadius = 16
        actionButtonTap.isHidden = !firstButton
        actionButtonTap.translatesAutoresizingMaskIntoConstraints = false
        actionButtonTap.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(actionButtonTap)

        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 66),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            actionButtonTap.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonTap.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButtonTap.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            actionButtonTap.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func tap() {
        onStartTap?()
    }
}

