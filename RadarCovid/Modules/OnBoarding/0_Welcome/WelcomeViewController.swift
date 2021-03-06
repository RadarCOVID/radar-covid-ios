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

class WelcomeViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var languageSelectorContainerView: UIView!
    @IBOutlet weak var languageSelectorLabel: UILabel!
    @IBOutlet weak var stepbullet1Label: UILabel!
    @IBOutlet weak var stepbullet2Label: UILabel!
    @IBOutlet weak var stepbullet3Label: UILabel!
    
    var router: AppRouter?
    var viewModel: WelcomeViewModel?
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @IBAction func onContinue(_ sender: Any) {
        router?.route(to: .onBoarding, from: self)
    }
    
    @objc func selectLanguage(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        
        isDisableAccesibility(isDisabble: true)
        self.navigationController?.topViewController?.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            SelectorView
                .initWithParentViewController(
                    viewController: self,
                    title: "SETTINGS_LANGUAGE_TITLE".localized,
                    getArray: { () -> Observable<[SelectorItem]> in
                        viewModel.getLenguages().map { locales in SelectorHelperViewModel.generateTransformation(val: locales) }
                    }, getSelectedItem: { () -> Observable<SelectorItem> in
                            viewModel.getCurrenLenguageLocalizable().map { value in
                                SelectorHelperViewModel.generateTransformation(
                                    val: ItemLocale(id: viewModel.getCurrenLenguage(),
                                                    description: value))
                            }
                }, delegateOutput: self)
        }
    }
    
    private func setupAccessibility() {
        
        languageSelectorContainerView.isAccessibilityElement = true
        languageSelectorContainerView.accessibilityHint = "ACC_HINT".localized

        continueButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)
        continueButton.isAccessibilityElement = true
        continueButton.accessibilityLabel = "ACC_BUTTON_CONTINUE".localized
        continueButton.accessibilityHint = "ACC_HINT".localized
        continueButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)

        titleLabel?.accessibilityLabel = "ACC_WELCOME_TITLE".localized
    }
    
    private func setupView() {

        languageSelectorContainerView.layer.borderWidth = 1
        languageSelectorContainerView.layer.borderColor = UIColor.deepLilac.cgColor
        languageSelectorContainerView.layer.cornerRadius = 8
        
        languageSelectorContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                  action: #selector(selectLanguage(_ :))))
        
        viewModel?.getCurrenLenguageLocalizable().subscribe(onNext: { [weak self] (value) in
            self?.languageSelectorContainerView.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized + " " + (value) + " " + "ACC_SELECTED".localized
            self?.languageSelectorLabel.text = value
            self?.languageSelectorLabel.setMagnifierFontSize()
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

            self.showAlertCancelContinue(title: "LOCALE_CHANGE_LANGUAGE".localizedAttributed,
                                                          message: "LOCALE_CHANGE_WARNING".localizedAttributed,
                                                          buttonOkTitle: "ALERT_ACCEPT_BUTTON".localized,
                                                          buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
                                                          buttonOkVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized,
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
