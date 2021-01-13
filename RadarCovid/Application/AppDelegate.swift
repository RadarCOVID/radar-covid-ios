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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if Config.debug {
            setupLog()
        }
        
        logger.info("Current Environment: \(Config.environment)")
        
        if DP3TTracing.isOSCompatible {
            let setupUseCase = injection.resolve(SetupUseCase.self)!
            let fakeRequestUseCase = injection.resolve(FakeRequestUseCase.self)!
            if #available(iOS 13.0, *) {
                fakeRequestUseCase.initBackgroundTask()
            }
            bluethoothUseCase = injection.resolve(BluethoothReminderUseCase.self)!
            do {
                try setupUseCase.initializeSDK()
            } catch {
                logger.error("Error initializing DP3T \(error)")
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //Loading initial screen, only execut iOS 12.5
        if #available(iOS 13.0, *) {
        } else {
            loadInitialScreen(initWindow: UIWindow(frame: UIScreen.main.bounds),  url: nil)
        }
        
        return true
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if #available(iOS 13.0, *) {
        } else {
            loadViewToUrl(url: url)
        }
        
        return true
    }
    
    func loadInitialScreen(initWindow: UIWindow?, url: URL?) {
        
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        
        if let initialiceWindow = initWindow {
            window = initialiceWindow
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        if DP3TTracing.isOSCompatible {
            if let url = url {
                loadViewToUrl(url: url)
            } else {
                router?.route(to: Routes.root, from: navigationController)
            }
        } else {
            router?.route(to: Routes.unsupportedOS, from: navigationController)
        }
    }
    
    func loadViewToUrl(url: URL) {
        if DP3TTracing.isOSCompatible {
            deepLinkUseCase?.getScreenFor(url: url, window: window, router: router)
        } else {
            router?.route(to: Routes.unsupportedOS, from: UINavigationController())
        }
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
