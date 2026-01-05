import UIKit
// Экран выбора фильтров для трекеров
final class FiltersViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedFilter: TrackerFilter
    private let onFilterSelected: (TrackerFilter) -> Void
    
    private let filters: [TrackerFilter] = [.all, .today, .completed, .uncompleted]
    
    // MARK: - UI Elements
    // Таблица с фильтрами
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(resource: .ypBackground)
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    init(selectedFilter: TrackerFilter, onFilterSelected: @escaping (TrackerFilter) -> Void) {
        self.selectedFilter = selectedFilter
        self.onFilterSelected = onFilterSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }
    
    // Настройка навигационной панели
    private func setupNavigationBar() {
        navigationItem.title = Localizable.filtersTitle
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    // Добавляет разделитель в ячейку таблицы
    private func addSeparator(to cell: UITableViewCell) {
        let separator = UIView()
        separator.backgroundColor = UIColor(resource: .ypGray)
        separator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    // Настраивает ячейку для отображения фильтра
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterTableViewCell else {
            return UITableViewCell()
        }
        
        let filter = filters[indexPath.row]
        let isSelected = filter == selectedFilter
        
        cell.configure(with: filter.title, isSelected: isSelected)
        
        if indexPath.row < filters.count - 1 {
            addSeparator(to: cell)
        }
        
        cell.backgroundColor = UIColor(resource: .ypBackground)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // Обрабатывает выбор фильтра
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        self.selectedFilter = selectedFilter
        onFilterSelected(selectedFilter)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        var maskedCorners: CACornerMask = []
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        
        switch indexPath.row {
        case 0:
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case totalRows - 1:
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            break
        }
        
        cell.layer.maskedCorners = maskedCorners
        cell.layer.cornerRadius = !maskedCorners.isEmpty ? cornerRadius : 0
        cell.layer.masksToBounds = !maskedCorners.isEmpty
    }
}
