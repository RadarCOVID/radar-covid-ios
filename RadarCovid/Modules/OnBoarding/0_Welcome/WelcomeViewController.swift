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

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var languageSelectorButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepbullet1Label: UILabel!
    @IBOutlet weak var stepbullet2Label: UILabel!
    @IBOutlet weak var stepbullet3Label: UILabel!
    
    var router: AppRouter?
    var viewModel: WelcomeViewModel?
    
    private var disposeBag = DisposeBag()
    
    private var currentLocale: String = "es-ES"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    @IBAction func onContinue(_ sender: Any) {
        router?.route(to: .onBoarding, from: self)
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        
        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            LanguageSelectionView.initWithParentViewController(viewController: self, viewModel: viewModel, delegateOutput: self)
        }
    }
    
    private func setupAccessibility() {
        
        languageSelectorButton.isAccessibilityElement = true
        languageSelectorButton.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized
        languageSelectorButton.accessibilityHint = "ACC_HINT".localized

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

        languageSelectorButton.layer.borderWidth = 1
        languageSelectorButton.layer.borderColor = UIColor.deepLilac.cgColor
        
        viewModel?.getCurrenLenguageLocalizable()
            .bind(to: languageSelectorButton.rx.title())
            .disposed(by: disposeBag)
        
        setupAccessibility()
    }
}

extension WelcomeViewController: LanguageSelectionProtocol {
    
    func userChangeLanguage() {
        self.router?.route(to: Routes.changeLanguage, from: self)
    }
}
