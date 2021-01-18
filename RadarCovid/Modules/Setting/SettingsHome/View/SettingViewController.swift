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

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var languageSelectorContainerView: BackgroundView!
    @IBOutlet weak var languageSelectorLabel: UILabel!
    @IBOutlet weak var infoContainerView: BackgroundView!
    
    var router: AppRouter?
    var viewModel: SettingViewModel?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        languageSelectorContainerView.isAccessibilityElement = true
        
        languageSelectorContainerView.accessibilityHint = "ACC_HINT".localized
        
        infoContainerView.isAccessibilityElement = true
        infoContainerView.accessibilityLabel = "SETTINGS_INFO_BUTTON".localized
        infoContainerView.accessibilityHint = "ACC_HINT".localized
    }
    
    @objc func onLanguageSelectionAction(_ sender: Any) {
        showLanguageSelection()
    }
    
    @IBAction func onInfoApp(_ sender: Any) {
        router?.route(to: .infoApp, from: self)
    }
    
    private func setupView() {
        viewModel?.getCurrenLenguageLocalizable().subscribe(onNext: { [weak self] (value) in
            self?.languageSelectorContainerView.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized + " " + (value) + " " + "ACC_SELECTED".localized
        }).disposed(by: disposeBag)
        
        languageSelectorContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                  action: #selector(onLanguageSelectionAction(_ :))))
        
        infoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action: #selector(onInfoApp(_ :))))

        languageSelectorContainerView.image = UIImage(named: "WhiteCard")
        infoContainerView.image = UIImage(named: "WhiteCard")
    }
    
    
    
    private func showLanguageSelection() {
        guard let viewModel = self.viewModel else { return }
        
        isDisableAccesibility(isDisabble: true)
        self.navigationController?.topViewController?.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            SelectorView
                .initWithParentViewController (
                    viewController: self,
                    title: "SETTINGS_LANGUAGE_TITLE".localized,
                    getArray: { () -> Observable<[SelectorItem]> in
                        viewModel.getLenguages().map { locales in SelectorHelperViewModel.generateTransformation(val: locales) }
                    },
                    getSelectedItem: { () -> Observable<SelectorItem> in
                                viewModel.getCurrenLenguageLocalizable().map { value in
                                    SelectorHelperViewModel.generateTransformation(
                                        val: ItemLocale(id: viewModel.getCurrenLenguage(),
                                                        description: value))
                                }
                    }, delegateOutput: self)
        }
    }
    
    private func isDisableAccesibility(isDisabble: Bool) {
        self.scrollView.isHidden = isDisabble
        
        if let tab = self.parent as? TabBarController {
            tab.isDissableAccesibility(isDisabble: isDisabble)
        }
    }
}

extension SettingViewController: SelectorProtocol {
    
    func userSelectorSelected(selectorItem: SelectorItem, completionCloseView: @escaping (Bool) -> Void) {
        
        if selectorItem.id != self.viewModel?.getCurrenLenguage() {
            
            self.showAlertCancelContinue(title: "LOCALE_CHANGE_LANGUAGE".localizedAttributed,
                                         message: "LOCALE_CHANGE_WARNING".localizedAttributed,
                                         buttonOkTitle: "ALERT_ACCEPT_BUTTON".localized,
                                         buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
                                         buttonOkVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized,
                                         buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized,
                                         okHandler: {
                                            completionCloseView(true)
                                            self.viewModel?.setCurrentLocale(key: selectorItem.id)
                                            self.router?.route(to: Routes.changeLanguage, from: self, parameters: SettingViewController.self)
                                         }, cancelHandler: {
                                            completionCloseView(false)
                                         })
        } else {
            completionCloseView(true)
        }
    }
    
    func hiddenSelectorSelectionView() {
        isDisableAccesibility(isDisabble: false)
    }
}

extension SettingViewController: AccTitleView {

    var accTitle: String? {
        get {
            "SETTINGS_TITLE".localized
        }
    }
}

