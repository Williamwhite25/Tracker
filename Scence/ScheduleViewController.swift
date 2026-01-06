import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    var selectedDays: [Weekday] = []
    var onDaysSelected: (([Weekday]) -> Void)?
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(resource: .ypBackground)
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = Localizable.doneButton
        configuration.baseForegroundColor = UIColor(resource: .ypWhite)
        configuration.baseBackgroundColor = UIColor(resource: .ypBlack)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 16
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigationBar() {
        title = Localizable.scheduleScreenTitle
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
        
        navigationItem.hidesBackButton = true
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        onDaysSelected?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let weekday = Weekday.allCases[indexPath.row]
        let isSelected = selectedDays.contains(weekday)
        
        cell.configure(with: weekday.localizedName, isOn: isSelected)
        cell.onSwitchChanged = { [weak self] isOn in
            if isOn {
                self?.selectedDays.append(weekday)
            } else {
                self?.selectedDays.removeAll { $0 == weekday }
            }
        }
        
        if indexPath.row < Weekday.allCases.count - 1 {
            addSeparator(to: cell)
        }
        
        cell.backgroundColor = UIColor(resource: .ypBackground)
        return cell
    }
    
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

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
