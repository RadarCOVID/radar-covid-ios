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

class DetailInteroperabilityViewController: BaseViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var bottomCloseButton: UIButton!
    @IBOutlet weak var description1Label: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var listCountryStackView: UIStackView!
    
    var router: AppRouter?
    var viewModel: DetailInteroperabilityViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.loadCountries()
        setupView()
        setupAccessibility()
        setupBinding()
    }
        
    private func setupAccessibility() {
        closeButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        closeButton.accessibilityHint = "ACC_HINT".localized
        closeButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        bottomCloseButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        bottomCloseButton.accessibilityHint = "ACC_HINT".localized
        bottomCloseButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
    }
    
    private func setupView() {
        self.description1Label.setLineSpacing()
        self.description2Label.setLineSpacing()
    }
    
    private func setupBinding() {
        viewModel?.getCountries().subscribe(onNext: { [weak self] (countries) in
            self?.listCountryStackView.arrangedSubviews.forEach {
                self?.listCountryStackView.removeArrangedSubview($0)
            }
            countries.forEach { (country) in
                let countryLabel = UILabel()
                countryLabel.text = country.description
                countryLabel.numberOfLines = 0
                countryLabel.font = UIFont.boldSystemFont(ofSize: 18)
                countryLabel.setMagnifierFontSize()
                countryLabel.textAlignment = NSTextAlignment.center
                countryLabel.setLineSpacing()
                self?.listCountryStackView.addArrangedSubview(countryLabel)
            }
        
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        router?.dissmiss(view: self, animated: true)
    }
}
