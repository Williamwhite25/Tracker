

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

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.isScrollEnabled = false
        tv.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        tv.backgroundView = nil
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        return tv
    }()

    private let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .black
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
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
        view.backgroundColor = .white
        title = "Расписание"

        view.addSubview(tableView)
        view.addSubview(doneButton)

        tableView.dataSource = self
        tableView.delegate = self

        // фиксированная высота строк, чтобы все ячейки были одинаковы
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80

        view.bringSubviewToFront(tableView)

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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 48)
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
        cell.contentConfiguration = content

        let sw = UISwitch()
        sw.isOn = selected[indexPath.row]
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = sw
        cell.selectionStyle = .none

        var bg = UIBackgroundConfiguration.listGroupedCell()
        bg.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        bg.cornerRadius = 8
        cell.backgroundConfiguration = bg

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


