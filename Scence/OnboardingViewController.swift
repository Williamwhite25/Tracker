import UIKit

final class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pageCheck = UIPageControl()
    private var pages: [OnboardingPageViewController] = []
    var onFinishTap: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageCheck.currentPageIndicatorTintColor = .ypBlack
        pageCheck.pageIndicatorTintColor = .ypGray

        let pageOne = OnboardingPageViewController(
            imageName: "onBoardingOne",
            title: "Отслеживайте только то, что хотите",
            firstButton: true
        )
        pageOne.onStartTap = { [weak self] in self?.finish() }

        let pageSecond = OnboardingPageViewController(
            imageName: "onBoardingSecond",
            title: "Даже если это не литры воды и йога",
            firstButton: true
        )
        pageSecond.onStartTap = { [weak self] in self?.finish() }

        pages = [pageOne, pageSecond]

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageCheck.numberOfPages = pages.count
        pageCheck.currentPage = 0
        pageCheck.isUserInteractionEnabled = false
        pageCheck.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageCheck)

        NSLayoutConstraint.activate([
            pageCheck.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageCheck.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168)
        ])
    }

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

