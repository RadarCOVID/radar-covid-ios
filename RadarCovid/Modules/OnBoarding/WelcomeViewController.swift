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

class WelcomeViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var languageSelector: UIButton!
    var router: AppRouter?
    @IBOutlet weak var viewTitle: UILabel!

    var localesKeysArray: [String] = []
    var localesArray: [String: String?]!
    var localizationRepository: LocalizationRepository!
    private var currentLocale: String = "es-ES"
    @IBOutlet weak var stepbullet1: UILabel!
    @IBOutlet weak var selectorView: BackgroundView!

    @IBOutlet weak var stepbullet2: UILabel!

    @IBOutlet weak var stepbullet3: UILabel!

    private var pickerPresenter: PickerPresenter?

    @IBAction func onContinue(_ sender: Any) {
        router?.route(to: .onBoarding, from: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        selectorView.image = UIImage.init(named: "WhiteCard")
        loadLocaleValues()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        pickerPresenter = PickerPresenter(picker: picker)
        pickerPresenter?.delegate = self
        setupAccessibility()
    }

    func setupAccessibility() {
        languageSelector.isAccessibilityElement = true
        languageSelector.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized
        languageSelector.accessibilityHint = "ACC_HINT".localized

        continueButton.setTitle("ONBOARDING_CONTINUE_BUTTON".localized, for: .normal)
        continueButton.isAccessibilityElement = true
        continueButton.accessibilityLabel = "ACC_BUTTON_CONTINUE".localized
        continueButton.accessibilityHint = "ACC_HINT".localized

        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityLabel = "ACC_WELCOME_TITLE".localized
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
    }

    private func loadLocaleValues() {

        if let locale = localizationRepository.getLocale() {
            currentLocale = locale
        }

        localesArray = localizationRepository.getLocales()

        let keys = Array(self.localesArray.keys) as [String]
        if let currentLanguage = localizationRepository.getLocale() {
            languageSelector.setTitle(localesArray[currentLanguage, default: ""], for: .normal)
        }

        guard let firstKey = keys.filter({ $0.contains(currentLocale) }).first else {
            self.localesKeysArray = keys
            return
        }
        let otherKeys = keys.filter {!$0.contains(currentLocale)}
        self.localesKeysArray.append(firstKey)
        self.localesKeysArray += otherKeys
    }

    @IBAction func selectLanguage(_ sender: Any) {
        pickerPresenter?.openPicker()
    }

}

extension WelcomeViewController: UIPickerViewDelegate, UIPickerViewDataSource, PickerDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return localesKeysArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let key = localesKeysArray[row]
        return localesArray[key] ?? ""

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let key = localesKeysArray[row]
        self.languageSelector.setTitle(self.localesArray[key, default: ""], for: .normal)
        localizationRepository.setLocale(key)
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        let key = localesKeysArray[row]
        let text = localesArray[key] ?? ""
        label.isAccessibilityElement = true
        label.accessibilityLabel = (text ?? "") + "ACC_SELECTED".localized
        label.contentMode = .center
        label.text = text
        return label
    }

    var containerView: UIView {
        get {
            view
        }
    }

    func onDone() {
        if currentLocale != localizationRepository.getLocale() {
            showAlertOk(title: "LOCALE_CHANGE_LANGUAGE".localized,
                             message: "LOCALE_CHANGE_WARNING".localized,
                             buttonTitle: "ALERT_OK_BUTTON".localized,
                             buttonVoiceover: "ACC_BUTTON_ALERT_OK".localized) { _ in
                exit(0)
            }
        }
    }
}
