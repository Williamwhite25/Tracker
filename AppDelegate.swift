//
//  AppDelegate.swift
//  Tracker
//
//  Created by William White on 02.11.2025.
//




import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                NSLog("Unresolved Core Data error: %@, %@", error, error.userInfo)
            } else {
                NSLog("Loaded persistent store: %@", storeDescription.url?.path ?? "<in-memory>")
            }

            // Настройки контекста после попытки загрузки store
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.undoManager = nil
        }

        return container
    }()

    // Удобный метод для сохранения контекста (можно вызывать из любого места через (UIApplication.shared.delegate as? AppDelegate)?.saveContext() )
    func saveContext(_ context: NSManagedObjectContext? = nil) {
        let ctx = context ?? persistentContainer.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            NSLog("Failed to save Core Data context: %@, %@", nsError, nsError.userInfo)
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Инициализация контейнера (при желании можно вызвать явно)
        _ = persistentContainer
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}




//import UIKit
//import CoreData
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    var window: UIWindow?
//
//
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        return true
//    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        
//    }
//    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "Model")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                
//                NSLog("Unresolved Core Data error: %@, %@", error, error.userInfo)
//
//            } else {
//                NSLog("Loaded persistent store: %@", storeDescription.url?.path ?? "<in-memory>")
//            }
//        })
//        return container
//    }()
//
//
//}
