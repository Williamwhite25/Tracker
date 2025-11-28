
//  Created by William White on 19.11.2025.
//



import Foundation
import UIKit

// MARK: - CollectionTracker: empty data view helper
extension CollectionTracker {
    func showEmptyDataView(visible: Bool) {
        if visible {
            emptyDataView.frame = collection.bounds
            emptyDataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collection.backgroundView = emptyDataView
            emptyDataView.isHidden = false
        } else {
            collection.backgroundView = nil
            emptyDataView.isHidden = true
        }
    }
}

// MARK: - CollectionTracker
final class CollectionTracker: NSObject {
    // Public collection view
    public let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInsetReference = .fromSafeArea
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let presenter: TrackerPresenterProtocol
    private let emptyDataView: UIView = UIView()
    private var items: [UUID: [Tracker]]?

    init(presenter: TrackerPresenterProtocol) {
        self.presenter = presenter
    }

    // Register and add collection to presenter's view
    func register(by items: [UUID: [Tracker]]? = nil) -> Self {
        self.items = items

        if let presenterVC = presenter as? UIViewController {
            presenterVC.view.addSubview(collection)
            collection.translatesAutoresizingMaskIntoConstraints = false

            collection.delegate = presenterVC as? UICollectionViewDelegate
            collection.dataSource = presenterVC as? UICollectionViewDataSource

            collection.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
            collection.register(
                TrackerHeaderCollection.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: TrackerHeaderCollection.identifier
            )

            NSLayoutConstraint.activate([
                collection.topAnchor.constraint(equalTo: presenterVC.view.topAnchor),
                collection.bottomAnchor.constraint(equalTo: presenterVC.view.safeAreaLayoutGuide.bottomAnchor),
                collection.leadingAnchor.constraint(equalTo: presenterVC.view.safeAreaLayoutGuide.leadingAnchor),
                collection.trailingAnchor.constraint(equalTo: presenterVC.view.safeAreaLayoutGuide.trailingAnchor)
            ])

            createEmptyDataView(message: "Что будем отслеживать?")
        }

        return self
    }

    // Create a background view shown when there is no data
    private func createEmptyDataView(message: String) {
        guard let img = UIImage(named: "Logo") else {
            assertionFailure("Asset 'Logo' not found")
            return
        }

        let imageNoData = UIImageView(image: img)
        let textLabel = UILabel()

        textLabel.text = message
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(named: "YPBlack") ?? .black
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0

        // Background view should resize with collection; internal views use Auto Layout
        emptyDataView.translatesAutoresizingMaskIntoConstraints = true
        emptyDataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        emptyDataView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.15)
        emptyDataView.layer.borderWidth = 1
        emptyDataView.layer.borderColor = UIColor.red.cgColor

        imageNoData.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyDataView.addSubview(imageNoData)
        emptyDataView.addSubview(textLabel)

        imageNoData.contentMode = .scaleAspectFit

        // Set as background view (hidden by default)
        collection.backgroundView = emptyDataView
        emptyDataView.isHidden = true

        // Internal constraints relative to emptyDataView
        NSLayoutConstraint.activate([
            imageNoData.centerXAnchor.constraint(equalTo: emptyDataView.centerXAnchor),
            imageNoData.topAnchor.constraint(equalTo: emptyDataView.topAnchor, constant: 16),
            imageNoData.widthAnchor.constraint(equalToConstant: 80),
            imageNoData.heightAnchor.constraint(equalToConstant: 80),

            textLabel.topAnchor.constraint(equalTo: imageNoData.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: emptyDataView.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: emptyDataView.trailingAnchor, constant: -16)
        ])

        emptyDataView.frame = collection.bounds
    }
}




