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
import RxSwift
import DP3TSDK

class RootViewController: UIViewController {

    var router: AppRouter!
    var configurationUseCase: ConfigurationUseCase!
    var ccaaUseCase: CCAAUseCase!
    var localesUseCase: LocalesUseCase!
    var localizationUseCase: LocalizationUseCase!
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase!
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    var urlSchemeRedirect: [Routes]?
    var selectTabType: UIViewController.Type?
    var paramsUrlScheme: [Any?]?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadLocalesAndCCAA()
    }
    
    private func loadLocalesAndCCAA() {
        
        LocalizationHolder.source = localizationUseCase
        // change to wait for all request before load localization
        Observable.zip(localesUseCase!.loadLocales(),
                       ccaaUseCase!.loadCCAA()).subscribe(
            // we dont use any of the avove so it is _,
            // otherwise it would be the name of a variable
            // that repesent the return of the observables in order
            onNext: { [weak self] (_, _) in
                // all is ok so we can continue
                self?.loadLocalization()

        }, onError: {[weak self] (_) in
            // we get an error so we stop working
            // Not use i18n for this alert!
            self?.showAlertOk(title: "Error",
                              message: "Se ha producido un error. Compruebe la conexión",
                              buttonTitle: "Aceptar") {
                exit(0)
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func loadLocalization() {
    
        localizationUseCase.loadlocalization().subscribe(
            onNext: { [weak self] settings in
                self?.loadConfiguration()

            }, onError: {  [weak self] error in
                // we get an error so we stop working
                // Not use i18n for this alert!
                self?.showAlertOk(title: "Error",
                                  message: "Se ha producido un error. Compruebe la conexión",
                                  buttonTitle: "Aceptar") {
                    exit(0)
                }

        }).disposed(by: disposeBag)
    }
    
    private func loadConfiguration() {
        
        configurationUseCase.loadConfig().subscribe(
            onNext: { [weak self] settings in
                debugPrint("Configuration  finished")

                if (!DP3TTracing.isOSCompatible) {
                    self?.navigateToUnsupportedOS()
                } else if settings.isUpdated ?? false {
                    self?.navigateFirst()
                } else {
                    self?.showUpdateNoticeForSettings(settings: settings)
                }

            }, onError: {  [weak self] error in
                debugPrint("Configuration errro \(error)")
                
                self?.showAlertOk(title: "ALERT_GENERIC_ERROR_TITLE".localized,
                                  message: "ALERT_GENERIC_ERROR_CONTENT".localized,
                                  buttonTitle: "ALERT_ACCEPT_BUTTON".localized) {
                    self?.navigateFirst()
                }

        }).disposed(by: disposeBag)
    }
    
    private func showUpdateNoticeForSettings(settings: Settings) {
        if #available(iOS 13.7, *) {
            
            let configUrl = settings.parameters?.applicationVersion?.ios?.bundleUrl
                ?? "itms-apps://itunes.apple.com"
            self.showAlertOk(title: "ALERT_UPDATE_TEXT_TITLE".localized,
                              message: "ALERT_UPDATE_TEXT_CONTENT".localized,
                              buttonTitle: "ALERT_UPDATE_BUTTON".localized
                              ) { 
                if let url = NSURL(string: configUrl) as URL? {
                    UIApplication.shared.open(url) { _ in
                        exit(0)
                    }
                }
            }  
        }
    }

    private func navigateFirst() {

        if (!DP3TTracing.isOSCompatible) {
            navigateToUnsupportedOS()
        } else if onBoardingCompletedUseCase.isOnBoardingCompleted() {
            venueRecordUseCase.isCheckedIn().subscribe( onNext: { [weak self] checkedIn in
                self?.navigateIfCheckedIn(checkedIn)
            }).disposed(by: disposeBag)
        } else {
            router.route(to: .welcome, from: self)
        }

    }
    
    private func navigateIfCheckedIn(_ checkedIn: Bool) {
        if checkedIn {
            router.route(to: .checkedIn, from: self)
        } else if let urlSchemeRedirect = urlSchemeRedirect {
            router.routes(to: urlSchemeRedirect, from: self, parameters: paramsUrlScheme)
        } else {
            router.route(to: Routes.home, from: self, parameters: selectTabType)
        }
    }
    
    private func navigateToUnsupportedOS() {
        router.route(to: .unsupportedOS, from: self)
    }

}
