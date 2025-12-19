import UIKit


// MARK: - ScheduleViewControllerDelegate
protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays selectedDays: [WeekDay])
}

// MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    // MARK: Properties
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let weekdays = WeekDay.allCases
    private var selected: [Bool]
    
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Расписание"
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
        
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.isScrollEnabled = false
        tv.rowHeight = 75
        tv.backgroundColor = UIColor(red: 0.902, green: 0.910, blue: 0.922, alpha: 0.302)
        tv.separatorStyle = .singleLine
        tv.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        return tv
    }()
    
    
    private let doneButton: UIButton = {
        var config = UIButton(type: .system)
        config.setTitle("Готово", for: .normal)
        config.backgroundColor = .ypBlack
        config.setTitleColor(.ypWhite, for: .normal)
        config.titleLabel?.font = .systemFont(ofSize: 16)
        config.layer.cornerRadius = 16
        
        config.translatesAutoresizingMaskIntoConstraints = false
        return config
    }()
    
    private var didLayoutOnce = false
    
    // MARK: Init
    init(initialSelectedDays: [WeekDay] = []) {
        var sel = Array(repeating: false, count: WeekDay.allCases.count)
        for day in initialSelectedDays {
            sel[day.index] = true
        }
        self.selected = sel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        //        tableView.estimatedRowHeight = 75
        
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutOnce {
            tableView.reloadData()
            didLayoutOnce = true
        }
    }
    
    // MARK: Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: Actions
    @objc private func doneTapped() {
        let selectedDays = weekdays.enumerated().compactMap { idx, day in
            selected[idx] ? day : nil
        }
        delegate?.scheduleViewController(self, didSelectDays: selectedDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { weekdays.count }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = weekdays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = day.displayName
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        content.textProperties.color = .label
        cell.contentConfiguration = content
        
        cell.selectionStyle = .none
        cell.backgroundConfiguration = .clear()
        
        // accessory: switch
        let sw = UISwitch()
        sw.isOn = selected[indexPath.row]
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = sw
        
        let dividerTag = 999
        let dividerColor = UIColor(named: "YPGray") ?? UIColor.systemGray4
        if let existing = cell.contentView.viewWithTag(dividerTag) {
            existing.isHidden = (indexPath.row == weekdays.count - 1)
        } else {
            let divider = UIView()
            divider.tag = dividerTag
            divider.backgroundColor = dividerColor
            divider.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(divider)
            
            NSLayoutConstraint.activate([
                
                divider.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                divider.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                divider.heightAnchor.constraint(equalToConstant: 0.5),
                divider.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
            divider.isHidden = (indexPath.row == weekdays.count - 1)
        }
        
        if indexPath.row == weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    // При тапе по строке переключаем состояние и обновляем UISwitch
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected[indexPath.row].toggle()
        if let cell = tableView.cellForRow(at: indexPath),
           let sw = cell.accessoryView as? UISwitch {
            sw.setOn(selected[indexPath.row], animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .clear
    }
}

// MARK: - Private actions
private extension ScheduleViewController {
    @objc func switchChanged(_ sender: UISwitch) {
        let idx = sender.tag
        guard idx >= 0 && idx < selected.count else { return }
        selected[idx] = sender.isOn
    }
}


