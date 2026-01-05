import UIKit
import CoreData
import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Store Properties
    private(set) lazy var trackerCategoryStore: TrackerCategoryStore = {
        TrackerCategoryStore(context: CoreDataManager.shared.viewContext)
    }()
    
    private(set) lazy var trackerStore: TrackerStore = {
        TrackerStore(context: CoreDataManager.shared.viewContext)
    }()
    
    private(set) lazy var trackerRecordStore: TrackerRecordStore = {
        TrackerRecordStore(context: CoreDataManager.shared.viewContext)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 🔹 Инициализация AppMetrica
            AnalyticsService.activate()
            
            print("AppMetrica configured with API key")
            
            let defaults = UserDefaults.standard
            if !defaults.bool(forKey: "hasPreloadedData") {
                defaults.set(true, forKey: "hasPreloadedData")
            }
            
            return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}
