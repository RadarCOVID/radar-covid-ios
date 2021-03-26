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
        case config
        case kpi
        case verification
        case problematic
    }
    
    private let container: Container
    
    init() {
        
        container = Container()
        
        container.register(SwaggerClientAPI.self, name: Endpoint.config.rawValue) { _ in
            let swaggerApi = SwaggerClientAPI()
            swaggerApi.basePath = Config.endpoints.config
            return swaggerApi
        }.inObjectScope(.container)
        
        container.register(SwaggerClientAPI.self, name: Endpoint.verification.rawValue) { _ in
            let swaggerApi = SwaggerClientAPI()
            swaggerApi.basePath = Config.endpoints.verification
            return swaggerApi
        }.inObjectScope(.container)
        
        container.register(SwaggerClientAPI.self, name: Endpoint.kpi.rawValue) { _ in
            let swaggerApi = SwaggerClientAPI()
            swaggerApi.basePath = Config.endpoints.kpi
            return swaggerApi
        }.inObjectScope(.container)
        
        container.register(SwaggerClientAPI.self, name: Endpoint.problematic.rawValue) { _ in
            let swaggerApi = SwaggerClientAPI()
            swaggerApi.basePath = Config.endpoints.problematic
            return swaggerApi
        }.inObjectScope(.container)
        
        container.register(TokenAPI.self) { r in
            TokenAPI(clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.config.rawValue)!)
        }.inObjectScope(.container)
        
        container.register(SettingsAPI.self) { r in
            SettingsAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.config.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(TextsAPI.self) { r in
            TextsAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.config.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(MasterDataAPI.self) { r in
            MasterDataAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.config.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(StatisticsAPI.self) { r in
            StatisticsAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.config.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(VerificationControllerAPI.self) { r in
            VerificationControllerAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.verification.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(AppleKpiControllerAPI.self) { r in
            AppleKpiControllerAPI(
                clientApi: r.resolve(SwaggerClientAPI.self, name: Endpoint.kpi.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(ProblematicEventsApi.self) { r in
            ProblematicEventsApiImpl(clientApi:  r.resolve(SwaggerClientAPI.self, name: Endpoint.problematic.rawValue)!
            )
        }.inObjectScope(.container)
        
        container.register(PreferencesRepository.self) { _ in
            UserDefaultsPreferencesRepository()
        }.inObjectScope(.container)
        
        container.register(TermsAcceptedRepository.self) { _ in
            TermsAcceptedRepository()
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
        
        container.register(CountriesRepository.self) { _ in
            UserDefaultsCountriesRepository()
        }.inObjectScope(.container)
        
        container.register(StatisticsRepository.self) { _ in
            UserDefaultsStatisticsRepository()
        }.inObjectScope(.container)
        
        container.register(AnalyticsRepository.self) { _ in
            UserDefaultsAnalyticsRepository()
        }.inObjectScope(.container)
        
        container.register(ExposureKpiRepository.self) { _ in
            UserDefaultsExposureKpiRepository()
        }.inObjectScope(.container)
        
        container.register(VenueRecordRepository.self) { _ in
            KeyStoreVenueRecordRepository()
        }.inObjectScope(.container)
        
        container.register(QrCheckRepository.self) { _ in
            UserDefaultsQrCheckRepository()
        }.inObjectScope(.container)
        
        container.register(VersionHandler.self) { _ in
            VersionHandler()
        }.inObjectScope(.container)
        
        container.register(NotificationHandler.self) { _ in
            NotificationHandlerImpl()
        }.inObjectScope(.container)
        
        container.register(DeviceTokenHandler.self) { r in
            DCDeviceTokenHandler()
        }.inObjectScope(.container)
        
        container.register(AppStateHandler.self) { r in
            AppStateHandlertImpl()
        }.inObjectScope(.container)
        
        container.register(AuthenticationHandler.self) { r in
            AuthenticationHandler()
        }.inObjectScope(.container)
        
        container.register(VenueNotifier.self) { r in
            VenueNotifierImpl(baseUrl: Config.endpoints.qrBase)
        }.inObjectScope(.container)
        
        container.register(OnboardingCompletedUseCase.self) { r in
            OnboardingCompletedUseCase(preferencesRepository: r.resolve(PreferencesRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(ExpositionUseCase.self) { r in
            ExpositionUseCaseImpl(notificationHandler: r.resolve(NotificationHandler.self)!,
                              expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!,
                              venueExpositionUseCase: r.resolve(VenueExpositionUseCase.self)!)
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
            FakeRequestUseCaseImpl(settingsRepository: r.resolve(SettingsRepository.self)!,
                               verificationApi: r.resolve(VerificationControllerAPI.self)!,
                               xx: r.resolve(FakeRequestRepository.self)!)
        }.inObjectScope(.container)
        
        if #available(iOS 13.0, *) {
            container.register(FakeRequestBackgroundTask.self) { r in
                r.resolve(FakeRequestUseCase.self) as! FakeRequestBackgroundTask
            }
        }
        
        container.register(ConfigurationUseCase.self) { r in
            ConfigurationUseCaseImpl(settingsRepository: r.resolve(SettingsRepository.self)!,
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
                         backgroundTaskUseCase: r.resolve(BackgroundTasksUseCase.self)!,
                         expositionUseCase: r.resolve(ExpositionUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(BackgroundTasksUseCase.self) { r in
            BackgroundTasksUseCaseImpl(analyticsUseCase: r.resolve(AnalyticsUseCase.self)!,
                                   fakeRequestUseCase: r.resolve(FakeRequestUseCase.self)!,
                                   expositionCheckUseCase: r.resolve(ExpositionCheckUseCase.self)!,
                                   checkInInprogressUseCase: r.resolve(CheckInInProgressUseCase.self)!,
                                   configurationUseCase: r.resolve(ConfigurationUseCase.self)!,
                                   problematicEventsUseCase: r.resolve(ProblematicEventsUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(LocalizationUseCase.self) { r in
            LocalizationUseCase(textsApi: r.resolve(TextsAPI.self)!,
                                localizationRepository: r.resolve(LocalizationRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(CCAAUseCase.self) { r in
            CCAAUseCase(masterDataApi: r.resolve(MasterDataAPI.self)!,
                        localizationRepository: r.resolve(LocalizationRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(ShareUseCase.self) { r in
            ShareUseCaseImpl(settingsRepository: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(LocalesUseCase.self) { r in
            LocalesUseCase(localizationRepository: r.resolve(LocalizationRepository.self)!,
                           masterDataApi: r.resolve(MasterDataAPI.self)!)
        }.inObjectScope(.container)
        
        container.register(CountriesUseCase.self) { r in
            CountriesUseCase(
                countriesRepository: r.resolve(CountriesRepository.self)!,
                masterDataApi: r.resolve(MasterDataAPI.self)!,
                localizationRepository: r.resolve(LocalizationRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(StatisticsUseCase.self) { r in
            StatisticsUseCase(
                statisticsRepository: r.resolve(StatisticsRepository.self)!,
                statisticsApi: r.resolve(StatisticsAPI.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ExpositionCheckUseCase.self) { r in
            ExpositionCheckUseCaseImpl(
                expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!,
                settingsRepository: r.resolve(SettingsRepository.self)!,
                resetDataUseCase: r.resolve(ResetDataUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(DeepLinkUseCase.self) { r in
            DeepLinkUseCase(
                expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!,
                router: r.resolve(AppRouter.self)!,
                qrBase: Config.endpoints.qrBase)
        }.inObjectScope(.container)
        
        container.register(AnalyticsUseCase.self) { r in
            AnalyticsUseCaseImpl(deviceTokenHandler: r.resolve(DeviceTokenHandler.self)!,
                             analyticsRepository: r.resolve(AnalyticsRepository.self)!,
                             kpiApi: r.resolve(AppleKpiControllerAPI.self)!,
                             exposureKpiUseCase:  r.resolve(ExposureKpiUseCase.self)!,
                             settingsRepository: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(ExposureKpiUseCase.self) { r in
            ExposureKpiUseCaseImpl(expositionInfoRepository: r.resolve(ExpositionInfoRepository.self)!,
                               exposureKpiRepository: r.resolve(ExposureKpiRepository.self)!)
        }.inObjectScope(.container)
        
        
        container.register(ReminderNotificationUseCase.self) { r in
            let reminderNotificationUseCase = ReminderNotificationUseCase(settingsRepository: r.resolve(SettingsRepository.self)!)
            return reminderNotificationUseCase
        }.inObjectScope(.container)
        
        container.register(BluethoothReminderUseCase.self) { r in
            BluethoothReminderUseCase(notificationHandler: r.resolve(NotificationHandler.self)!)
        }.inObjectScope(.container)
        
        container.register(VenueRecordUseCase.self) { r in
            VenueRecordUseCaseImpl(venueRecordRepository: r.resolve(VenueRecordRepository.self)!,
                                   venueNotifier: r.resolve(VenueNotifier.self)!)
        }.inObjectScope(.container)
        
        container.register(ProblematicEventsUseCase.self) { r in
            ProblematicEventsUseCaseImpl(venueRecordRepository: r.resolve(VenueRecordRepository.self)!,                                                      qrCheckRepository: r.resolve(QrCheckRepository.self)!,
                                         venueNotifier: r.resolve(VenueNotifier.self)!,
                                         problematicEventsApi: r.resolve(ProblematicEventsApi.self)!,
                                         notificationHandler: r.resolve(NotificationHandler.self)!,
                                         settingsRepository: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(CheckInInProgressUseCase.self) { r in
            CheckInInProgressUseCaseImpl(notificationHandler: r.resolve(NotificationHandler.self)!,
                                         venueRecordRepository: r.resolve(VenueRecordRepository.self)!,
                                         qrCheckRepository: r.resolve(QrCheckRepository.self)!,
                                         appStateHandler: r.resolve(AppStateHandler.self)!,
                                         settinsRepository: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(VenueExpositionUseCase.self) { r in
            VenueExpositionUseCaseImpl(venueRecordRepository: r.resolve(VenueRecordRepository.self)!)
        }.inObjectScope(.container)
        
        
        container.register(TabBarController.self) { r in
            TabBarController(
                homeViewController: r.resolve(HomeViewController.self)!,
                helpLineViewController: r.resolve(HelpLineViewController.self)!,
                statsViewController: r.resolve(StatsViewController.self)!,
                settingViewController: r.resolve(SettingViewController.self)!,
                preferencesRepository: r.resolve(PreferencesRepository.self)!,
                localizationUseCase: r.resolve(LocalizationUseCase.self)!,
                venueRecordViewController: r.resolve(VenueRecordStartViewController.self)!,
                venueRecodrUseCase: r.resolve(VenueRecordUseCase.self)!
            )
        }
        
        container.register(AppRouter.self) { _ in
            AppRouter()
        }.initCompleted {r, appRouter in}
        
        container.register(ProximityViewController.self) {  r in
            let proxVC = ProximityViewController()
            proxVC.radarStatusUseCase = r.resolve(RadarStatusUseCase.self)!
            proxVC.router = r.resolve(AppRouter.self)!
            return proxVC
        }
        
        container.register(HealthyExpositionViewController.self) { r  in
            let vc = self.createViewController(
                storyboard: "HealthyExposition",
                viewId: "HealthyExpositionViewController"
            ) as? HealthyExpositionViewController ?? HealthyExpositionViewController()
            vc.router = r.resolve(AppRouter.self)!
            return vc
        }
        
        container.register(HighExpositionViewController.self) {  r in
            let highExposition = self.createViewController(
                storyboard: "HighExposition",
                viewId: "HighExpositionViewController")
                as? HighExpositionViewController ?? HighExpositionViewController()
            highExposition.ccaUseCase = r.resolve(CCAAUseCase.self)!
            highExposition.settingsRepository = r.resolve(SettingsRepository.self)!
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
            homeVC?.termsRepository = r.resolve(TermsAcceptedRepository.self)!
            return homeVC!
        }
        
        container.register(HomeViewModel.self) { route in
            let homeVM = HomeViewModel()
            homeVM.problematicEventsUseCase = route.resolve(ProblematicEventsUseCase.self)!
            homeVM.expositionUseCase = route.resolve(ExpositionUseCase.self)!
            homeVM.radarStatusUseCase = route.resolve(RadarStatusUseCase.self)!
            homeVM.resetDataUseCase = route.resolve(ResetDataUseCase.self)!
            homeVM.expositionCheckUseCase = route.resolve(ExpositionCheckUseCase.self)!
            homeVM.settingsRepository = route.resolve(SettingsRepository.self)!
            homeVM.onBoardingCompletedUseCase = route.resolve(OnboardingCompletedUseCase.self)!
            homeVM.reminderNotificationUseCase = route.resolve(ReminderNotificationUseCase.self)!
            return homeVM
        }
        
        container.register(HelpLineViewController.self) {  route in
            let helpVC = self.createViewController(
                storyboard: "HelpLine",
                viewId: "HelpLineViewController") as? HelpLineViewController
            helpVC?.router = route.resolve(AppRouter.self)!
            helpVC?.preferencesRepository = route.resolve(PreferencesRepository.self)!
            return helpVC!
        }
        
        container.register(StatsViewController.self) {  route in
            let statsVC = StatsViewController()
            statsVC.router = route.resolve(AppRouter.self)!
            statsVC.viewModel = route.resolve(StatsViewModel.self)!
            return statsVC
        }
        
        container.register(StatsViewModel.self) { route in
            let statsVM = StatsViewModel()
            statsVM.countriesUseCase = route.resolve(CountriesUseCase.self)!
            statsVM.statsUseCase = route.resolve(StatisticsUseCase.self)!
            return statsVM
        }
        
        container.register(SettingViewController.self) {  route in
            let settingVC = SettingViewController()
            settingVC.router = route.resolve(AppRouter.self)!
            settingVC.viewModel = route.resolve(SettingViewModel.self)!
            return settingVC
        }
        
        container.register(SettingViewModel.self) { route in
            let settingVM = SettingViewModel(localesUseCase: route.resolve(LocalesUseCase.self)!)
            return settingVM
        }
        
        container.register(InformationViewController.self) {  route in
            let informationVC = InformationViewController()
            informationVC.router = route.resolve(AppRouter.self)!
            informationVC.viewModel = route.resolve(InformationViewModel.self)!
            return informationVC
        }
        
        container.register(InformationViewModel.self) { route in
            let informationVM = InformationViewModel(radarStatusUseCase: route.resolve(RadarStatusUseCase.self)!,
                                                     expositionUseCase: route.resolve(ExpositionUseCase.self)!)
            return informationVM
        }

        container.register(MyHealthStep0ViewController.self) {  route in
            let myHealthStep0 = MyHealthStep0ViewController()
            myHealthStep0.router = route.resolve(AppRouter.self)!
            return myHealthStep0
        }
        
        container.register(MyHealthStep1ViewController.self) {  route in
            let myHealthStep1 = MyHealthStep1ViewController()
            myHealthStep1.router = route.resolve(AppRouter.self)!
            return myHealthStep1
        }
        
        container.register(MyHealthStep2ViewController.self) {  route in
            let myHealthStep2 = MyHealthStep2ViewController()
            myHealthStep2.router = route.resolve(AppRouter.self)!
            myHealthStep2.diagnosisCodeUseCase = route.resolve(DiagnosisCodeUseCase.self)!
            return myHealthStep2
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
            onbVC?.termsRepository = route.resolve(TermsAcceptedRepository.self)!
            return onbVC!
        }
        
        container.register(WelcomeViewController.self) {  r in
            let welcomeVC = WelcomeViewController()
            welcomeVC.viewModel = r.resolve(WelcomeViewModel.self)!
            welcomeVC.router = r.resolve(AppRouter.self)!
            return welcomeVC
        }
        
        container.register(WelcomeViewModel.self) { route in
            let welcomeVM = WelcomeViewModel(localesUseCase: route.resolve(LocalesUseCase.self)!)
            return welcomeVM
        }
        
        container.register(ShareAppViewController.self) {  r in
            let shareAppVC = ShareAppViewController()
            shareAppVC.viewModel = r.resolve(ShareAppViewModel.self)!
            shareAppVC.router = r.resolve(AppRouter.self)!
            return shareAppVC
        }
        
        container.register(ShareAppViewModel.self) { route in
            let shareAppVM = ShareAppViewModel(shareUseCase: route.resolve(ShareUseCase.self)!)
            return shareAppVM
        }
        
        container.register(TimeExposedViewController.self) {  r in
            let timeExposedVC = TimeExposedViewController()
            timeExposedVC.viewModel = r.resolve(TimeExposedViewModel.self)!
            timeExposedVC.router = r.resolve(AppRouter.self)!
            return timeExposedVC
        }
        
        container.register(TimeExposedViewModel.self) { route in
            let timeExposedVM = TimeExposedViewModel()
            return timeExposedVM
        }
        
        container.register(TermsUpdatedViewController.self) {  r in
            let termsUpdatedVC = TermsUpdatedViewController()
            termsUpdatedVC.viewModel = r.resolve(TermsUpdatedViewModel.self)!
            termsUpdatedVC.router = r.resolve(AppRouter.self)!
            return termsUpdatedVC
        }
        
        container.register(TermsUpdatedViewModel.self) { route in
            let termsUpdatedVM = TermsUpdatedViewModel()
            return termsUpdatedVM
        }
        
        container.register(DetailInteroperabilityViewController.self) {  r in
            let detailInteroperabilityVC = DetailInteroperabilityViewController()
            detailInteroperabilityVC.viewModel = r.resolve(DetailInteroperabilityViewModel.self)!
            detailInteroperabilityVC.router = r.resolve(AppRouter.self)!
            return detailInteroperabilityVC
        }
        
        container.register(DetailInteroperabilityViewModel.self) { route in
            let detailInteroperabilityVM = DetailInteroperabilityViewModel()
            detailInteroperabilityVM.countriesUseCase = route.resolve(CountriesUseCase.self)!
            return detailInteroperabilityVM
        }
        
        container.register(ActivateCovidNotificationViewController.self) {  r in
            let activateCovidVC = ActivateCovidNotificationViewController()
            activateCovidVC.router = r.resolve(AppRouter.self)!
            activateCovidVC.onBoardingCompletedUseCase = r.resolve(OnboardingCompletedUseCase.self)!
            activateCovidVC.radarStatusUseCase = r.resolve(RadarStatusUseCase.self)!
            activateCovidVC.errorHandler = r.resolve(ErrorHandler.self)!
            return activateCovidVC
        }
        
        container.register(HelpSettingsViewController.self) {  r in
            let helpSettingsVC = HelpSettingsViewController()
            helpSettingsVC.router = r.resolve(AppRouter.self)!
            return helpSettingsVC
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
            rootVC.configurationUseCase = r.resolve(ConfigurationUseCase.self)!
            rootVC.localizationUseCase = r.resolve(LocalizationUseCase.self)!
            rootVC.onBoardingCompletedUseCase = r.resolve(OnboardingCompletedUseCase.self)!
            rootVC.venueRecordUseCase = r.resolve(VenueRecordUseCase.self)!
            rootVC.router = r.resolve(AppRouter.self)!
            return rootVC
        }
        
        container.register(UnsupportedOSViewController.self) { r in
            let unsupportedOSVC = UnsupportedOSViewController()
            return unsupportedOSVC
        }
        
        container.register(VenueRecordStartViewController.self) { r in
            let vc = VenueRecordStartViewController()
            vc.router = r.resolve(AppRouter.self)!
            vc.venueRecordUseCase = r.resolve(VenueRecordUseCase.self)!
            vc.authenticationHandler = r.resolve(AuthenticationHandler.self)!
            return vc
        }
        
        container.register(QrScannerViewController.self) { r in
            let vc = QrScannerViewController()
            vc.router = r.resolve(AppRouter.self)!
            vc.venueRecordUseCase = r.resolve(VenueRecordUseCase.self)!
            return vc
        }
        
        container.register(QrResultViewController.self) { r in
            let vc = QrResultViewController()
            vc.router = r.resolve(AppRouter.self)!
            vc.venueRecordUseCase = r.resolve(VenueRecordUseCase.self)
            return vc
        }
        
        container.register(QrErrorViewController.self) { r in
            let vc = QrErrorViewController()
            vc.router = r.resolve(AppRouter.self)!
            return vc
        }
    
        container.register(CheckedInViewController.self) { r in
            let vc = CheckedInViewController()
            vc.router = r.resolve(AppRouter.self)!
            vc.venueRecordUseCase = r.resolve(VenueRecordUseCase.self)!
            return vc
        }
        
        container.register(CheckOutViewController.self) { r in
            let vc = CheckOutViewController()
            vc.router = r.resolve(AppRouter.self)!
            vc.venueRecordUseCase = r.resolve(VenueRecordUseCase.self)
            return vc
        }
        
        container.register(CheckOutConfirmationViewController.self) { r in
            let vc = CheckOutConfirmationViewController()
            vc.router = r.resolve(AppRouter.self)!
            return vc
        }
        
        container.register(VenueListViewModel.self) { r in
            let vm = VenueListViewModel()
            vm.venueRecordRepository = r.resolve(VenueRecordRepository.self)!
            return vm
        }
        
        
        container.register(VenueListViewController.self) { r in
            let vc = VenueListViewController()
            vc.router = r.resolve(AppRouter.self)!
            vc.viewModel = r.resolve(VenueListViewModel.self)!
            return vc
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
