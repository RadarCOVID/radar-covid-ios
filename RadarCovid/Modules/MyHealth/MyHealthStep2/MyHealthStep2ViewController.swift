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

class MyHealthStep2ViewController: UIViewController {
    
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
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
    }
    
    private func setupView() {
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.twilight.cgColor
        
        sendButton.setTitle("MY_HEALTH_DIAGNOSTIC_CODE_SEND_BUTTON".localized, for: .normal)
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
        shareSpainRadioView.setShadow()
        shareSpainRadioView.isUserInteractionEnabled = true
        shareSpainRadioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShareSpain)))
        
        shareEuropeRadioView.setShadow()
        shareEuropeRadioView.isUserInteractionEnabled = true
        shareEuropeRadioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShareEurope)))
        
        customSliderView.configure(indexStep: 2, totalStep: 2)
    }
    
    private func setupAccessibility() {

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_MY_DIAGNOSTIC_TITLE".localized
        
        sendButton.isAccessibilityElement = true
        sendButton.accessibilityLabel = "ACC_BUTTON_ALERT_CONTINUE".localized
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityLabel = "ACC_BUTTON_ALERT_CANCEL".localized
    }

    private func navigateIf(reported: Bool) {
        if reported {
            router?.route(to: Routes.myHealthReported, from: self)
        }
    }
    
    @objc private func onShareSpain() {
        self.checkShareEuropeImage.isHidden = true
        self.checkShareSpainImage.isHidden = false
    }
    
    @objc private func onShareEurope() {
        self.checkShareEuropeImage.isHidden = false
        self.checkShareSpainImage.isHidden = true
    }
    
    @IBAction func onReportDiagnosis(_ sender: Any) {
        
        guard let codigoString = codeString  else {
            return
        }
        
        view.showLoading()

        diagnosisCodeUseCase?.sendDiagnosisCode(code: codigoString, date: dateNotificationPositive ?? Date()).subscribe(
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
        
        if let diagnosisError = error as? DiagnosisError {
            switch diagnosisError {
            case .apiRejected:
                errorMessage = "ALERT_SHARING_REJECTED_ERROR".localized
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

        showAlertOk(
            title: title,
            message: errorMessage,
            buttonTitle: "ALERT_OK_BUTTON".localized,
            buttonVoiceover: "ACC_BUTTON_ALERT_OK".localized
        )
    }
}
