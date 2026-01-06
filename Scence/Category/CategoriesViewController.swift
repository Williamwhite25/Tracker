import UIKit

final class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: CategoriesViewModel!
    private var onCategorySelect: ((String) -> Void)?
    private var selectedCategoryTitle: String?
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(resource: .ypWhite)
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var placeholderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.habitsEventsGrouped
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.addCategory, for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    init(trackerCategoryStore: TrackerCategoryStore, selectedCategoryTitle: String? = nil, onCategorySelect: ((String) -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = CategoriesViewModel(trackerCategoryStore: trackerCategoryStore)
        self.selectedCategoryTitle = selectedCategoryTitle
        self.onCategorySelect = onCategorySelect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadCategories()
        setupInitialSelection()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        title = Localizable.categoryTitle
        
        view.addSubview(tableView)
        view.addSubview(placeholderStackView)
        view.addSubview(addCategoryButton)
        
        placeholderStackView.addArrangedSubview(placeholderView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            placeholderView.widthAnchor.constraint(equalToConstant: 80),
            placeholderView.heightAnchor.constraint(equalToConstant: 80),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.setHidesBackButton(true, animated: false)
        
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
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onEmptyStateChange = { [weak self] isEmpty in
            self?.tableView.isHidden = isEmpty
            self?.placeholderStackView.isHidden = !isEmpty
        }
        
        viewModel.onCategorySelect = { [weak self] categoryTitle in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.onCategorySelect?(categoryTitle)
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(message: "\(Localizable.errorMessage): \(error.localizedDescription)")
        }
    }
    
    private func setupInitialSelection() {
        guard let selectedCategoryTitle = selectedCategoryTitle else { return }
        
        for i in 0..<viewModel.getCategoriesCount() {
            if viewModel.getCategoryTitle(at: i) == selectedCategoryTitle {
                viewModel.selectCategory(at: i)
                break
            }
        }
    }
    
    // MARK: - Context Menu Configuration
    private func makeContextMenu(for category: TrackerCategory, at indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(
            title: Localizable.editAction,
            image: nil,
            attributes: []
        ) { [weak self] _ in
            self?.editCategory(category)
        }
        
        let deleteAction = UIAction(
            title: Localizable.deleteAction,
            image: nil,
            attributes: .destructive
        ) { [weak self] _ in
            self?.showDeleteConfirmation(for: category, at: indexPath)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController(trackerCategoryStore: trackerCategoryStore)
        newCategoryVC.onCategoryAdded = { [weak self] in
            self?.viewModel.loadCategories()
        }
        let navController = UINavigationController(rootViewController: newCategoryVC)
        present(navController, animated: true)
    }
    
    private func editCategory(_ category: TrackerCategory) {
        let editCategoryVC = EditCategoryViewController(
            trackerCategoryStore: trackerCategoryStore,
            category: category
        )
        editCategoryVC.onCategoryUpdated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        let navController = UINavigationController(rootViewController: editCategoryVC)
        present(navController, animated: true)
    }
    
    private func showDeleteConfirmation(for category: TrackerCategory, at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: Localizable.deleteConfirmationTitle,
            message: Localizable.deleteConfirmationMessage,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: Localizable.deleteButton, style: .destructive) { [weak self] _ in
            self?.deleteCategory(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: Localizable.cancelButton, style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        do {
            try viewModel.deleteCategory(at: indexPath.row)
        } catch {
            showErrorAlert(message: "\(Localizable.errorMessage)")
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: Localizable.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Localizable.doneButton, style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private var trackerCategoryStore: TrackerCategoryStore {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.trackerCategoryStore
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCategoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.getCategory(at: indexPath.row)
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        let isLastCell = indexPath.row == viewModel.getCategoriesCount() - 1
        
        cell.configure(with: category.title, isSelected: isSelected, isLastCell: isLastCell)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.handleCategorySelection(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        var corners: UIRectCorner = []
        
        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        
        if indexPath.row == viewModel.getCategoriesCount() - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        
        switch corners.isEmpty {
        case false:
            let path = UIBezierPath(
                roundedRect: cell.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            cell.layer.mask = mask
            
        case true:
            cell.layer.mask = nil
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.getCategory(at: indexPath.row)
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            return self?.makeContextMenu(for: category, at: indexPath)
        }
    }
}
