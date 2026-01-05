import UIKit

final class EditCategoryViewController: UIViewController {
    
    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStore
    private let category: TrackerCategory
    var onCategoryUpdated: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Localizable.categoryNamePlaceholder
        textField.backgroundColor = UIColor(resource: .ypBackground)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.text = category.title
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.doneButton, for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    init(trackerCategoryStore: TrackerCategoryStore, category: TrackerCategory) {
        self.trackerCategoryStore = trackerCategoryStore
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateDoneButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        view.addSubview(titleTextField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupNavigationBar() {
        title = Localizable.editCategory
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .ypWhite)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func updateDoneButtonState() {
        let isTextValid = !(titleTextField.text?.isEmpty ?? true) && titleTextField.text != category.title
        doneButton.isEnabled = isTextValid
        doneButton.backgroundColor = isTextValid ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    @objc private func doneButtonTapped() {
        guard let newTitle = titleTextField.text, !newTitle.isEmpty, newTitle != category.title else { return }
        
        do {
            try trackerCategoryStore.updateCategory(category, with: newTitle)
            onCategoryUpdated?()
            dismiss(animated: true)
        } catch {
            print("Error updating category: \(error)")
            showErrorAlert()
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: Localizable.errorTitle,
            message: Localizable.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Localizable.doneButton, style: .default))
        present(alert, animated: true)
    }
}

extension EditCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
