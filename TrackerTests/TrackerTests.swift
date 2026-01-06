import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerViewControllerSnapshotTests: XCTestCase {
    
    func testMainScreenLightMode() {
        // Given
        let vc = TrackerViewController()
        
        // When
        vc.loadViewIfNeeded()
        
        // Then
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "main_screen_light",
            record: false
        )
    }
    
    func testMainScreenDarkMode() {
        // Given
        let vc = TrackerViewController()
        
        // When
        vc.loadViewIfNeeded()
        
        // Then
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "main_screen_dark",
            record: false
        )
    }
}

