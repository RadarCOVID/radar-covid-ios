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
import RxCocoa

class SettingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageSelectorContainerView: UIView!
    @IBOutlet weak var languageSelectorLabel: UILabel!
    
    var router: AppRouter?
    var viewModel: SettingViewModel?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()
        
        setupView()
        setupAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .layoutChanged, argument: self.titleLabel)
            }
        }
    }
    
    private func setupAccessibility() {
        languageSelectorContainerView.isAccessibilityElement = true
        languageSelectorContainerView.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized
        languageSelectorContainerView.accessibilityHint = "ACC_HINT".localized
    }
    
    @objc func onLanguageSelectionAction(_ sender: Any) {
        showLanguageSelection()
    }
    
    private func setupView() {
        viewModel?.getCurrenLenguageLocalizable().subscribe(onNext: { [weak self] (value) in
            self?.languageSelectorLabel.text = value
            self?.languageSelectorContainerView.accessibilityLabel = value
        }).disposed(by: disposeBag)
        
        languageSelectorContainerView.layer.borderWidth = 1
        languageSelectorContainerView.layer.borderColor = UIColor.deepLilac.cgColor
        languageSelectorContainerView.layer.cornerRadius = 8
        
        languageSelectorContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                  action: #selector(onLanguageSelectionAction(_ :))))   
    }
    
    private func showLanguageSelection() {
        guard let viewModel = self.viewModel else { return }
        
        isDisableAccesibility(isDisabble: true)
        self.navigationController?.topViewController?.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            SelectorView.initWithParentViewController(viewController: self,
                                                      title: "SETTINGS_LANGUAGE_TITLE".localized,
                                                      getArray:{ [weak self] () -> Observable<[SelectorItem]> in
                                                        
                                                        return Observable.create { [weak self] observer in
                                                            viewModel.getLenguages().subscribe(onNext: {(value) in
                                                                observer.onNext(SelectorHelperViewModel.generateTransformation(val: value))
                                                                observer.onCompleted()
                                                            }).disposed(by: self?.disposeBag ?? DisposeBag())
                                                            return Disposables.create {
                                                            }
                                                        }
                                                      }, getSelectedItem: { () -> Observable<SelectorItem> in
                                                        
                                                        return Observable.create { [weak self] observer in
                                                            viewModel.getCurrenLenguageLocalizable().subscribe(onNext: {(value) in
                                                                observer.onNext(SelectorHelperViewModel.generateTransformation(val: ItemLocale(id: viewModel.getCurrenLenguage(), description: value)))
                                                                observer.onCompleted()
                                                            }).disposed(by: self?.disposeBag ?? DisposeBag())
                                                            return Disposables.create {
                                                            }
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
                                         buttonOkTitle: "ALERT_OK_BUTTON".localized,
                                         buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
                                         buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localized,
                                         buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized,
                                         okHandler: {
                                            completionCloseView(true)
                                            self.viewModel?.setCurrentLocale(key: selectorItem.id)
                                            self.router?.route(to: Routes.changeLanguage, from: self)
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

