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

class WelcomeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var languageSelectorContainerView: UIView!
    @IBOutlet weak var languageSelectorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepbullet1Label: UILabel!
    @IBOutlet weak var stepbullet2Label: UILabel!
    @IBOutlet weak var stepbullet3Label: UILabel!
    
    var router: AppRouter?
    var viewModel: WelcomeViewModel?
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()
        setupView()
    }
    
    @IBAction func onContinue(_ sender: Any) {
        router?.route(to: .onBoarding, from: self)
    }
    
    @objc func selectLanguage(_ sender: Any) {
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
    
    private func setupAccessibility() {
        
        languageSelectorContainerView.isAccessibilityElement = true
        languageSelectorContainerView.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized
        languageSelectorContainerView.accessibilityHint = "ACC_HINT".localized

        continueButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)
        continueButton.isAccessibilityElement = true
        continueButton.accessibilityLabel = "ACC_BUTTON_CONTINUE".localized
        continueButton.accessibilityHint = "ACC_HINT".localized
        continueButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = "ACC_WELCOME_TITLE".localized
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
    }
    
    private func setupView() {

        languageSelectorContainerView.layer.borderWidth = 1
        languageSelectorContainerView.layer.borderColor = UIColor.deepLilac.cgColor
        languageSelectorContainerView.layer.cornerRadius = 8
        
        languageSelectorContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                  action: #selector(selectLanguage(_ :))))
        
        viewModel?.getCurrenLenguageLocalizable().subscribe(onNext: { [weak self] (value) in
            self?.languageSelectorLabel.text = value
            self?.languageSelectorContainerView.accessibilityLabel = value
        }).disposed(by: disposeBag)
        
        setupAccessibility()
    }
    
    private func isDisableAccesibility(isDisabble: Bool) {
        self.scrollView.isHidden = isDisabble
        self.continueButton.isHidden = isDisabble
    }
}

extension WelcomeViewController: SelectorProtocol {
    
    func userSelectorSelected(selectorItem: SelectorItem, completionCloseView: @escaping (Bool) -> Void) {
        
        if selectorItem.id != self.viewModel?.getCurrenLenguage() {

            self.showAlertCancelContinue(title: "LOCALE_CHANGE_LANGUAGE".localized,
                                                          message: "LOCALE_CHANGE_WARNING".localized,
                                                          buttonOkTitle: "ALERT_OK_BUTTON".localized,
                                                          buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
                                                          buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localized,
                                                          buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized,
                                                          okHandler: { _ in
                                                            completionCloseView(true)
                                                            self.viewModel?.setCurrentLocale(key: selectorItem.id)
                                                            self.router?.route(to: Routes.changeLanguage, from: self)
                                                          }, cancelHandler: { _ in
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
