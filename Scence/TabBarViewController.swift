import UIKit

final class TrackerTabsController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        addTabBarSeparator()
    }
    
    private func setupTabBar() {
        guard view.frame.size.height > 0, view.frame.size.width > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupTabBar()
            }
            return
        }
        let trackersNavVC = UINavigationController(rootViewController: TrackersViewController())
        let statisticsNavVC = UINavigationController(rootViewController: StatisticsViewController())
        
        trackersNavVC.tabBarItem = UITabBarItem(
            title: Localizable.trackersTab,
            image: UIImage(resource: .trackerLogo),
            selectedImage: nil
        )
        
        statisticsNavVC.tabBarItem = UITabBarItem(
                    title: Localizable.statisticsTab,
                    image: UIImage(resource: .statisticLogo),
                    selectedImage: nil
                )
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .kern: -0.24
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        
        viewControllers = [trackersNavVC, statisticsNavVC]
        
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = UIColor(resource: .ypBlue)
        
        DispatchQueue.main.async {
            self.adjustTabBarHeight()
        }
    }
    
    private func addTabBarSeparator() {
        let separator = UIView()
        separator.backgroundColor = UIColor(resource: .ypGray)
        separator.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func adjustTabBarHeight() {
        let newHeight: CGFloat = 84
        guard newHeight > 0, view.frame.size.height > 0 else { return }
        var newFrame = tabBar.frame
        newFrame.size.height = newHeight
        newFrame.origin.y = view.frame.size.height - newHeight
        tabBar.frame = newFrame
    }
    
    private var hasAdjustedTabBar = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasAdjustedTabBar && view.frame.size.height > 0 {
            adjustTabBarHeight()
            hasAdjustedTabBar = true
        }
    }
}
