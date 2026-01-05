import UIKit

// MARK: - OnboardingViewController
final class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Private Properties
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pageCheck = UIPageControl()
    private var pages: [OnboardingPageViewController] = []
    
    // MARK: - Public Properties
    var onFinishTap: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageCheck.currentPageIndicatorTintColor = .ypBlack
        pageCheck.pageIndicatorTintColor = .ypGray

        let pageOne = OnboardingPageViewController(
            imageName: "onBoardingOne",
            title: NSLocalizedString("onboarding.page1.title", comment: ""),
            firstButton: true
        )
        pageOne.onStartTap = { [weak self] in self?.finish() }

        let pageSecond = OnboardingPageViewController(
            imageName: "onBoardingSecond",
            title: NSLocalizedString("onboarding.page2.title", comment: ""),
            firstButton: true
        )
        pageSecond.onStartTap = { [weak self] in self?.finish() }

        pages = [pageOne, pageSecond]

        // Настройка PageViewController
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка constraints для PageViewController
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Настройка PageControl
        pageCheck.numberOfPages = pages.count
        pageCheck.currentPage = 0
        pageCheck.isUserInteractionEnabled = false
        pageCheck.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageCheck)

        // Установка constraints для PageControl
        NSLayoutConstraint.activate([
            pageCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageCheck.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168)
        ])
    }

    // MARK: - Private Methods
    private func finish() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        dismiss(animated: true) { [weak self] in self?.onFinishTap?() }
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let viewController = viewController as? OnboardingPageViewController,
            let index = pages.firstIndex(where: { $0 === viewController }),
            index > 0
        else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let viewController = viewController as? OnboardingPageViewController,
            let index = pages.firstIndex(where: { $0 === viewController }),
            index < pages.count - 1
        else { return nil }
        return pages[index + 1]
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            completed,
            let current = pageViewController.viewControllers?.first as? OnboardingPageViewController,
            let index = pages.firstIndex(where: { $0 === current })
        else { return }
        pageCheck.currentPage = index
        pageCheck.currentPageIndicatorTintColor = .ypBlack
        pageCheck.pageIndicatorTintColor = .ypGray
    }
}

