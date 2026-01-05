import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: Constants.appMetricaKey) else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(_ event: AnalyticsEvent) {
        AppMetrica.reportEvent(
            name: event.name,
            parameters: event.params,
            onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            }
        )
        
        print("Analytics Event: \(event.name) - \(event.params)")
    }
}

private enum Constants {
    static let appMetricaKey = "5f47d978-ab36-4939-8647-d3aec3a584c0"
}
