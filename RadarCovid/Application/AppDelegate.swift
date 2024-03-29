//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit
import Logging
import DP3TSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    var injection: Injection = Injection()
    var window: UIWindow?
    
    var bluethoothUseCase: BluethoothReminderUseCase?
    
    private let logger = Logger(label: "AppDelegate")
    
    private lazy var deepLinkUseCase: DeepLinkUseCase? = {
        return AppDelegate.shared?.injection.resolve(DeepLinkUseCase.self)!
    }()
    private lazy var router: AppRouter? = {
        return AppDelegate.shared?.injection.resolve(AppRouter.self)!
    }()
    
    private lazy var notificationHandler: NotificationHandler? = {
        return AppDelegate.shared?.injection.resolve(NotificationHandler.self)!
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if Config.activateLog {
            setupLog()
        }
        
        logger.info("Current Environment: \(Config.environment)")
        
        if DP3TTracing.isOSCompatible {
            let setupUseCase = injection.resolve(SetupUseCase.self)!
            if #available(iOS 13.0, *) {
                let fakeRequestUseCase = injection.resolve(FakeRequestBackgroundTask.self)!
                fakeRequestUseCase.initBackgroundTask()
            }
            bluethoothUseCase = injection.resolve(BluethoothReminderUseCase.self)!
            do {
                try setupUseCase.initializeSDK()
            } catch {
                logger.error("Error initializing DP3T \(error)")
            }
        }
        
        notificationHandler?.scheduleRemovalNotification()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
            //Loading initial screen, only execut iOS 12.5
        if #available(iOS 13.0, *) {
        } else {
            loadInitialScreen(initWindow: UIWindow(frame: UIScreen.main.bounds),  url: nil)
        }
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return loadInitialScreen(initWindow: nil, url: url)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL else {
            return false
        }

        return loadInitialScreen(initWindow: nil, url: incomingURL)

    }
    
    func loadInitialScreen(initWindow: UIWindow?, url: URL?) -> Bool {
        
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        
        if let initialiceWindow = initWindow {
            window = initialiceWindow
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        if let url = url {
            deepLinkUseCase?.routeTo(url: url, from: navigationController)
            return true
        }
        router?.route(to: Routes.root, from: navigationController)
        return false
    }
    
    private func setupLog() {
        NetworkActivityLogger.shared.startLogging()
        
        do {
            let logFileURL = getDocumentsDirectory().appendingPathComponent("radarcovid.log")
            let fileLogger = try FileLogging(to: logFileURL)
            
            LoggingSystem.bootstrap { label in
                var fileHandler = FileLogHandler(label: label, fileLogger: fileLogger)
                fileHandler.logLevel = .debug
                var stdHandler = StreamLogHandler.standardOutput(label: label)
                stdHandler.logLevel = .debug
                let handlers:[LogHandler] = [
                    fileHandler,
                    stdHandler
                ]
                return MultiplexLogHandler(handlers)
            }
            
        } catch {
            debugPrint("Error initializing log \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

@available(iOS 13.0, *)
extension AppDelegate {
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
