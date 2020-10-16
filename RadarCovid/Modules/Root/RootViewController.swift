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

class RootViewController: UIViewController {

    var router: AppRouter?
    var configurationUseCasee: ConfigurationUseCase?
    var ccaaUseCase: CCAAUseCase?
    var localesUseCase: LocalesUseCase?
    var localizationUseCase: LocalizationUseCase?
    var onBoardingCompletedUseCase: OnboardingCompletedUseCase?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLocalesAndCCAA()
    }
    
    private func loadLocalesAndCCAA() {
        
        LocalizationHolder.source = localizationUseCase
        // change to wait for all request before load localization
        Observable.zip(localesUseCase!.loadLocales(),
                       ccaaUseCase!.loadCCAA(),
                       localizationUseCase!.loadlocalization()).subscribe(
            // we dont use any of the avove so it is _,
            // otherwise it would be the name of a variable
            // that repesent the return of the observables in order
            onNext: { [weak self] (_, _, _) in
                // all is ok so we can continue
                self?.loadConfiguration()

        }, onError: {[weak self] (_) in
            // we get an error so we stop working
            // Not use i18n for this alert!
            self?.showAlertOk(title: "Error",
                              message: "Se ha producido un error. Compruebe la conexión",
                              buttonTitle: "Aceptar",
                              buttonVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized) { (_) in
                exit(0)
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func loadConfiguration() {
        configurationUseCasee!.loadConfig().subscribe(
            onNext: { [weak self] settings in
                debugPrint("Configuration  finished")

                if  settings.isUpdated ?? false {
                    self?.navigateFirst()
                } else {
                    let configUrl = settings.parameters?.applicationVersion?.ios?.bundleUrl
                        ?? "itms-apps://itunes.apple.com"
                    self?.showAlertOk(title: "ALERT_UPDATE_TEXT_TITLE".localized,
                                      message: "ALERT_UPDATE_TEXT_CONTENT".localized,
                                      buttonTitle: "ALERT_UPDATE_BUTTON".localized,
                                      buttonVoiceover: "ACC_BUTTON_ALERT_UPDATE".localized) { (_) in
                        if let url = NSURL(string: configUrl) as URL? {
                            UIApplication.shared.open(url) { _ in
                                exit(0)
                            }
                        }
                    }
                }

            }, onError: {  [weak self] error in
                debugPrint("Configuration errro \(error)")
                self?.showAlertOk(title: "ALERT_GENERIC_ERROR_TITLE".localized,
                                  message: "ALERT_GENERIC_ERROR_CONTENT".localized,
                                  buttonTitle: "ALERT_ACCEPT_BUTTON".localized,
                                  buttonVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized) { _ in
                    self?.navigateFirst()
                }

        }).disposed(by: disposeBag)
    }

    private  func navigateFirst() {
        router?.route(to: Routes.home, from: self)
//        if onBoardingCompletedUseCase?.isOnBoardingCompleted() ?? false {
//            router?.route(to: Routes.home, from: self)
//        } else {
//            router!.route(to: Routes.welcome, from: self)
//        }
    }

}
