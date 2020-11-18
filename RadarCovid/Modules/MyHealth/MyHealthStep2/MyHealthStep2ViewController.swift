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

class MyHealthStep2ViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customSliderView: CustomSliderView!
    @IBOutlet weak var shareSpainRadioView: UIView!
    @IBOutlet weak var checkShareSpainImage: UIImageView!
    @IBOutlet weak var shareEuropeRadioView: UIView!
    @IBOutlet weak var checkShareEuropeImage: UIImageView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var router: AppRouter?
    var diagnosisCodeUseCase: DiagnosisCodeUseCase?
    
    var codeString: String?
    var dateNotificationPositive: Date?
    
    private var shareEuropean: Bool {
        return self.checkShareEuropeImage.isHidden == false
            && self.checkShareSpainImage.isHidden == true
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }
    
    private func setupView() {
        self.title = "MY_HEALTH_TITLE_STEP2".localized
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.twilight.cgColor
        
        sendButton.setTitle("MY_HEALTH_DIAGNOSTIC_CODE_SEND_BUTTON".localized, for: .normal)
        sendButton.titleLabel?.lineBreakMode = .byWordWrapping
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
        shareSpainRadioView.setShadow()
        shareSpainRadioView.isUserInteractionEnabled = true
        shareSpainRadioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShareSpain)))
        
        shareEuropeRadioView.setShadow()
        shareEuropeRadioView.isUserInteractionEnabled = true
        shareEuropeRadioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShareEurope)))
        
        var accesibilityHelperSlider = "MY_HEALTH_SCREEN_POSITION".localized
        accesibilityHelperSlider = accesibilityHelperSlider.replacingOccurrences(of: "$1", with: "\(2)")
        accesibilityHelperSlider = accesibilityHelperSlider.replacingOccurrences(of: "$2", with: "\(2)")
        customSliderView.configure(indexStep: 2, totalStep: 2, accesibilityHelper: accesibilityHelperSlider)
    }
    
    private func setupAccessibility() {

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        shareSpainRadioView.isAccessibilityElement = true
        shareSpainRadioView.accessibilityLabel =  "ACC_NO_SELECTED".localized + ", " + "MY_HEALTH_STEP2_RADIO1".localizedAttributed.string
        shareSpainRadioView.accessibilityTraits.insert(UIAccessibilityTraits.button)
        
        shareEuropeRadioView.isAccessibilityElement = true
        shareEuropeRadioView.accessibilityLabel = "MY_HEALTH_STEP2_RADIO2".localizedAttributed.string
        shareEuropeRadioView.accessibilityTraits.insert(UIAccessibilityTraits.button)
        shareEuropeRadioView.accessibilityTraits.insert(UIAccessibilityTraits.selected)
        
        sendButton.isAccessibilityElement = true
        sendButton.accessibilityHint = "ACC_HINT".localized
        sendButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityHint = "ACC_BUTTON_ALERT_CANCEL".localized
        cancelButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
    }

    private func navigateIf(reported: Bool) {
        if reported {
            router?.route(to: Routes.myHealthReported, from: self)
        }
    }
    
    @objc private func onShareSpain() {
        checkShareEuropeImage.isHidden = true
        checkShareSpainImage.isHidden = false
        
        shareEuropeRadioView.accessibilityLabel = "ACC_NO_SELECTED".localized + ", " + "MY_HEALTH_STEP2_RADIO2".localizedAttributed.string
        shareSpainRadioView.accessibilityLabel = "MY_HEALTH_STEP2_RADIO1".localizedAttributed.string
        
        shareSpainRadioView.accessibilityTraits.insert(UIAccessibilityTraits.selected)
        shareEuropeRadioView.accessibilityTraits.remove(UIAccessibilityTraits.selected)
    }
    
    @objc private func onShareEurope() {
        checkShareEuropeImage.isHidden = false
        checkShareSpainImage.isHidden = true
        
        shareEuropeRadioView.accessibilityLabel = "MY_HEALTH_STEP2_RADIO2".localizedAttributed.string
        shareSpainRadioView.accessibilityLabel = "ACC_NO_SELECTED".localized + ", " + "MY_HEALTH_STEP2_RADIO1".localizedAttributed.string
        
        shareSpainRadioView.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        shareEuropeRadioView.accessibilityTraits.insert(UIAccessibilityTraits.selected)
    }
    
    @IBAction func onReportDiagnosis(_ sender: Any) {
        
        guard let codigoString = codeString  else {
            return
        }
        
        view.showLoading()

        diagnosisCodeUseCase?.sendDiagnosisCode(code: codigoString, date: dateNotificationPositive ?? Date(), share: self.shareEuropean).subscribe(
            onNext: { [weak self] reportedCodeBool in
                self?.view.hideLoading()
                self?.navigateIf(reported: reportedCodeBool)
            }, onError: {  [weak self] error in
                self?.handle(error: error)
                self?.view.hideLoading()
        }).disposed(by: disposeBag)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.router?.pop(from: self, animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.showAlertCancelContinue(
            title: "ALERT_MY_HEALTH_SEND_TITLE".localizedAttributed.string,
            message: "ALERT_MY_HEALTH_SEND_CONTENT".localizedAttributed.string,
            buttonOkTitle: "ALERT_OK_BUTTON".localizedAttributed.string,
            buttonCancelTitle: "ALERT_CANCEL_BUTTON".localizedAttributed.string,
            buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localizedAttributed.string,
            buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localizedAttributed.string,
            okHandler: { (_) in
                self.router?.popToRoot(from: self, animated: true)
        }, cancelHandler: { (_) in
        })
    }
    
    private func handle(error: Error) {
        
        debugPrint("Error sending diagnosis \(error)")
        var title = ""
        var errorMessage = "ALERT_MY_HEALTH_CODE_ERROR_CONTENT".localized
        var showAlet: Bool = true
        
        if let diagnosisError = error as? DiagnosisError {
            switch diagnosisError {
            case .apiRejected: showAlet = false
                break
            case .idAlreadyUsed:
                errorMessage = "ALERT_ID_ALREADY_USED".localized
            case .wrongId:
                errorMessage = "ALERT_MY_HEALTH_CODE_ERROR_CONTENT".localized
            case .noConnection:
                title  = "ALERT_NETWORK_ERROR_TITLE".localized
                errorMessage = "ALERT_POSITIVE_REPORT_NETWORK_ERROR_MESSAGE".localized
            default:
                break
            }
        }

        if showAlet {
            showAlertOk(
                title: title,
                message: errorMessage,
                buttonTitle: "ALERT_OK_BUTTON".localized,
                buttonVoiceover: "ACC_BUTTON_ALERT_OK".localized)
        }
        
    }
}
