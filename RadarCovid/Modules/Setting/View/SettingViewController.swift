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
    @IBOutlet weak var languageSelectorButton: UIButton!
    
    var router: AppRouter?
    var viewModel: SettingViewModel?

    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        languageSelectorButton.isAccessibilityElement = true
        languageSelectorButton.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized
        languageSelectorButton.accessibilityHint = "ACC_HINT".localized
    }
    
    @IBAction func onLanguageSelectionAction(_ sender: Any) {
        showLanguageSelection()
    }
    
    private func setupView() {        
        viewModel?.getCurrenLenguageLocalizable()
            .bind(to: languageSelectorButton.rx.title())
            .disposed(by: disposeBag)
            
        let leftImageSelectorButton:CGFloat = ((self.languageSelectorButton.frame.size.width / 2) + 30)
        self.languageSelectorButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: leftImageSelectorButton , bottom: 0, right: 0)
    }
    
    private func showLanguageSelection() {
        guard let viewModel = self.viewModel else { return }
        
        isDisableAccesibility(isDisabble: true)
        self.navigationController?.topViewController?.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            LanguageSelectionView.initWithParentViewController(viewController: self, viewModel: viewModel, delegateOutput: self)
        }
    }
    
    private func isDisableAccesibility(isDisabble: Bool) {
        self.scrollView.isHidden = isDisabble
        
        if let tab = self.parent as? TabBarController {
            tab.isDissableAccesibility(isDisabble: isDisabble)
        }
    }
}

extension SettingViewController: LanguageSelectionProtocol {
    
    func userChangeLanguage() {
        self.router?.route(to: Routes.changeLanguage, from: self)
    }
    
    func hiddenLanguageSelectionView() {
        isDisableAccesibility(isDisabble: false)
    }
}
