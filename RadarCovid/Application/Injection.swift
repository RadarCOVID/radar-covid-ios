//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import Swinject
import UIKit

class Injection {
    
    enum Endpoint: String {
        case CONFIG
        case KPI
        case VERIFICATION
    }
    
    private let container: Container
    
    init() {
        
        container = Container()
        
        container.register(SwaggerClientAPI.self, name: Endpoint.CONFIG.rawValue) { _ in
            let swaggerApi = SwaggerClientAPI()
            swaggerApi.basePath = Config.endpoints.config
            return swaggerApi
        }.inObjectScope(.container)
        
        container.register(SwaggerClientAPI.self, name: Endpoint.VERIFICATION.rawValue) { _ in
            let swaggerApi = SwaggerClientAPI()
            swaggerApi.basePath = Config.endpoints.verification
            return swaggerApi
        }.inObjectScope(.container)
        
        container.register(TokenAPI.self) { r in
            TokenAPI(clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.CONFIG.rawValue)!)
        }.inObjectScope(.container)
        
        container.register(SettingsAPI.self) { r in
            SettingsAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.CONFIG.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(TextsAPI.self) { r in
            TextsAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.CONFIG.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(MasterDataAPI.self) { r in
            MasterDataAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.CONFIG.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(VerificationControllerAPI.self) { r in
            VerificationControllerAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.VERIFICATION.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(PreferencesRepository.self) { _ in
            UserDefaultsPreferencesRepository()
        }.inObjectScope(.container)
        
        container.register(SettingsRepository.self) { _ in
            UserDefaultsSettingsRepository()
        }.inObjectScope(.container)
        
        container.register(FakeRequestRepository.self) { _ in
            FakeRequestRepository()
        }.inObjectScope(.container)
        
        container.register(ExpositionInfoRepository.self) { _ in
            UserDefaultsExpositionInfoRepository()
        }.inObjectScope(.container)
        
        container.register(LocalizationRepository.self) { _ in
            UserDefaultsLocalizationRepository()
        }.inObjectScope(.container)
        
        container.register(VersionHandler.self) { _ in
            VersionHandler()
        }.inObjectScope(.container)
        
        container.register(NotificationHandler.self) { _ in
            NotificationHandler()
        }.inObjectScope(.container)
        
        container.register(OnboardingCompletedUseCase.self) { r in
            OnboardingCompletedUseCase(preferencesRepository: r.resolve(PreferencesRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(ExpositionUseCase.self) { r in
            ExpositionUseCase(notificationHandler: r.resolve(NotificationHandler.self)!,
                              expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(RadarStatusUseCase.self) { r in
            RadarStatusUseCase(preferencesRepository: r.resolve(PreferencesRepository.self)!,
                               syncUseCase: r.resolve(SyncUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(ResetDataUseCase.self) { r in
            ResetDataUseCaseImpl(expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!)
        }.initCompleted {r, useCase in
            (useCase as! ResetDataUseCaseImpl).setupUseCase = r.resolve(SetupUseCase.self)!
        }.inObjectScope(.container)
        
        container.register(DiagnosisCodeUseCase.self) { r in
            DiagnosisCodeUseCase(settingsRepository: r.resolve(SettingsRepository.self)!,
                                 verificationApi: r.resolve(VerificationControllerAPI.self)!)
        }.inObjectScope(.container)
        
        container.register(FakeRequestUseCase.self) { r in
            FakeRequestUseCase(settingsRepository: r.resolve(SettingsRepository.self)!,
                               verificationApi: r.resolve(VerificationControllerAPI.self)!,
                               fakeRequestRepository: r.resolve(FakeRequestRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(ConfigurationUseCase.self) { r in
            ConfigurationUseCase(settingsRepository: r.resolve(SettingsRepository.self)!,
                                 tokenApi: r.resolve(TokenAPI.self)!,
                                 settingsApi: r.resolve(SettingsAPI.self)!,
                                 versionHandler: r.resolve(VersionHandler.self)!)
        }.inObjectScope(.container)
        
        container.register(SyncUseCase.self) { r in
            SyncUseCase(preferencesRepository: r.resolve(PreferencesRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(SetupUseCase.self) { r in
            SetupUseCase(preferencesRepository: r.resolve(PreferencesRepository.self)!,
                         notificationHandler: r.resolve(NotificationHandler.self)!,
                         expositionCheckUseCase: r.resolve(ExpositionCheckUseCase.self)!,
                         fakeRequestUseCase: r.resolve(FakeRequestUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(LocalizationUseCase.self) { r in
            LocalizationUseCase(textsApi: r.resolve(TextsAPI.self)!,
                                localizationRepository: r.resolve(LocalizationRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(CCAAUseCase.self) { r in
            CCAAUseCase(masterDataApi: r.resolve(MasterDataAPI.self)!,
                        localizationRepository: r.resolve(LocalizationRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(LocalesUseCase.self) { r in
            LocalesUseCase(localizationRepository: r.resolve(LocalizationRepository.self)!,
                           masterDataApi: r.resolve(MasterDataAPI.self)!)
        }.inObjectScope(.container)
        
        container.register(ExpositionCheckUseCase.self) { r in
            ExpositionCheckUseCase(
                expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!,
                settingsRepository: r.resolve(SettingsRepository.self)!,
                resetDataUseCase: r.resolve(ResetDataUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(TabBarController.self) { r in
            TabBarController(
                localizationUseCase: r.resolve(LocalizationUseCase.self)!,
                homeViewController: r.resolve(HomeViewController.self)!,
                myDataViewController: r.resolve(MyDataViewController.self)!,
                helpLineViewController: r.resolve(HelpLineViewController.self)!,
                preferencesRepository: r.resolve(PreferencesRepository.self)!
            )
        }
        
        container.register(AppRouter.self) { _ in
            AppRouter()
        }.initCompleted {r, appRouter in
            appRouter.rootVC = r.resolve(RootViewController.self)!
            appRouter.proxymityVC  = r.resolve(ProximityViewController.self)!
            appRouter.onBoardingVC = r.resolve(OnBoardingViewController.self)!
            appRouter.tabBarController = r.resolve(TabBarController.self)!
            appRouter.myHealthVC = r.resolve(MyHealthViewController.self)!
            appRouter.myHealthReportedVC = r.resolve(MyHealthReportedViewController.self)!
            appRouter.expositionVC = r.resolve(ExpositionViewController.self)!
            appRouter.highExpositionVC = r.resolve(HighExpositionViewController.self)!
            appRouter.positiveExposedVC = r.resolve(PositiveExposedViewController.self)!
            appRouter.welcomeVC = r.resolve(WelcomeViewController.self)!
            appRouter.activateCovid = r.resolve(ActivateCovidNotificationViewController.self)!
            appRouter.activatePush = r.resolve(ActivatePushNotificationViewController.self)!
            appRouter.homeVC = r.resolve(HomeViewController.self)!
        }
        
        container.register(ProximityViewController.self) {  r in
            let proxVC = ProximityViewController()
            proxVC.radarStatusUseCase = r.resolve(RadarStatusUseCase.self)!
            proxVC.router = r.resolve(AppRouter.self)!
            return proxVC
        }
        
        container.register(ExpositionViewController.self) { r  in
            let vc = self.createViewController(
                storyboard: "Exposition",
                viewId: "ExpositionViewController"
            ) as? ExpositionViewController ?? ExpositionViewController()
            vc.router = r.resolve(AppRouter.self)!
            return vc
        }
        
        container.register(HighExpositionViewController.self) {  r in
            let highExposition = self.createViewController(
                storyboard: "HighExposition",
                viewId: "HighExpositionViewController")
                as? HighExpositionViewController ?? HighExpositionViewController()
            highExposition.ccaUseCase = r.resolve(CCAAUseCase.self)!
            highExposition.router = r.resolve(AppRouter.self)!
            return highExposition
        }
        
        container.register(PositiveExposedViewController.self) { r in
            let vc = self.createViewController(
                storyboard: "PositiveExposed",
                viewId: "PositiveExposedViewController")
                as? PositiveExposedViewController ?? PositiveExposedViewController()
            vc.router = r.resolve(AppRouter.self)!
            return vc
        }
        
        container.register(HomeViewController.self) {  r in
            let homeVC = self.createViewController(
                storyboard: "Home",
                viewId: "HomeViewController"
            ) as? HomeViewController
            homeVC?.router = r.resolve(AppRouter.self)!
            homeVC?.viewModel = r.resolve(HomeViewModel.self)!
            homeVC?.errorHandler = r.resolve(ErrorHandler.self)!
            return homeVC!
        }
        
        container.register(HomeViewModel.self) { route in
            let homeVM = HomeViewModel()
            homeVM.expositionUseCase = route.resolve(ExpositionUseCase.self)!
            homeVM.radarStatusUseCase = route.resolve(RadarStatusUseCase.self)!
            homeVM.resetDataUseCase = route.resolve(ResetDataUseCase.self)!
            homeVM.expositionCheckUseCase = route.resolve(ExpositionCheckUseCase.self)!
            homeVM.syncUseCase = route.resolve(SyncUseCase.self)!
            homeVM.onBoardingCompletedUseCase = route.resolve(OnboardingCompletedUseCase.self)!
            return homeVM
        }
        
        container.register(MyDataViewController.self) {  _ in
            self.createViewController(
                storyboard: "MyData",
                viewId: "MyDataViewController") as? MyDataViewController ?? MyDataViewController()
        }
        
        container.register(HelpLineViewController.self) {  route in
            let helpVC = self.createViewController(
                storyboard: "HelpLine",
                viewId: "HelpLineViewController") as? HelpLineViewController
            helpVC?.router = route.resolve(AppRouter.self)!
            helpVC?.preferencesRepository = route.resolve(PreferencesRepository.self)!
            return helpVC!
        }
        
        container.register(MyHealthViewController.self) {  route in
            let myHealthVC = self.createViewController(
                storyboard: "MyHealth",
                viewId: "MyHealthViewController") as? MyHealthViewController
            myHealthVC?.diagnosisCodeUseCase = route.resolve(DiagnosisCodeUseCase.self)!
            myHealthVC?.router = route.resolve(AppRouter.self)!
            return myHealthVC!
        }
        
        container.register(MyHealthReportedViewController.self) { route in
            let myHealthReportedVC = self.createViewController(
                storyboard: "MyHealthReported",
                viewId: "MyHealthReportedViewController") as? MyHealthReportedViewController
            myHealthReportedVC?.router = route.resolve(AppRouter.self)!
            return myHealthReportedVC!
        }
        
        container.register(OnBoardingViewController.self) {  route in
            let onbVC = self.createViewController(
                storyboard: "OnBoarding",
                viewId: "OnBoardingViewController") as? OnBoardingViewController
            onbVC?.router = route.resolve(AppRouter.self)!
            return onbVC!
        }
        
        container.register(WelcomeViewController.self) {  r in
            let welcomeVC = WelcomeViewController()
            welcomeVC.localizationRepository = r.resolve(LocalizationRepository.self)!
            welcomeVC.router = r.resolve(AppRouter.self)!
            return welcomeVC
        }
        
        container.register(ActivateCovidNotificationViewController.self) {  r in
            let activateCovidVC = ActivateCovidNotificationViewController()
            activateCovidVC.router = r.resolve(AppRouter.self)!
            activateCovidVC.onBoardingCompletedUseCase = r.resolve(OnboardingCompletedUseCase.self)!
            activateCovidVC.radarStatusUseCase = r.resolve(RadarStatusUseCase.self)!
            activateCovidVC.errorHandler = r.resolve(ErrorHandler.self)!
            return activateCovidVC
        }
        
        container.register(ActivatePushNotificationViewController.self) {  r in
            let activatePushVC = ActivatePushNotificationViewController()
            activatePushVC.router = r.resolve(AppRouter.self)!
            activatePushVC.notificationHandler = r.resolve(NotificationHandler.self)
            return activatePushVC
        }
        
        container.register(RootViewController.self) { r in
            let rootVC = RootViewController()
            rootVC.ccaaUseCase = r.resolve(CCAAUseCase.self)!
            rootVC.localesUseCase = r.resolve(LocalesUseCase.self)!
            rootVC.configurationUseCasee = r.resolve(ConfigurationUseCase.self)!
            rootVC.localizationUseCase = r.resolve(LocalizationUseCase.self)!
            rootVC.onBoardingCompletedUseCase = r.resolve(OnboardingCompletedUseCase.self)!
            rootVC.router = r.resolve(AppRouter.self)!
            return rootVC
        }
        
        container.register(ErrorRecorder.self) { _ in
            ErrorRecorderImpl()
        }
        
        container.register(ErrorHandler.self) { r in
            let errorHandler = ErrorHandlerImpl(verbose: Config.errorVerbose)
            errorHandler.errorRecorder = r.resolve(ErrorRecorder.self)!
            return errorHandler
        }
        
    }
    
    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return container.resolve(serviceType)
    }
    
    private func createViewController(storyboard: String, viewId: String) -> UIViewController {
        UIStoryboard(name: storyboard, bundle: Bundle.main)
            .instantiateViewController(withIdentifier: viewId)
    }
}
