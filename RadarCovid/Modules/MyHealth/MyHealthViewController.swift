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

class MyHealthViewController: UIViewController, UITextFieldDelegate {
    private let disposeBag = DisposeBag()

    @IBOutlet weak var scrollViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    var diagnosisCodeUseCase: DiagnosisCodeUseCase?
    var statusBar: UIView?
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codigoTitle: UILabel!

    @IBOutlet weak var sendDiagnosticButton: UIButton!
    var router: AppRouter?

    @IBOutlet var codeChars: [UITextField]!

    @IBAction func onBack(_ sender: Any) {
        self.showAlertCancelContinue(
            title: "ALERT_MY_HEALTH_SEND_TITLE".localizedAttributed.string,
            message: "ALERT_MY_HEALTH_SEND_CONTENT".localizedAttributed.string,
            buttonOkTitle: "ALERT_OK_BUTTON".localizedAttributed.string,
            buttonCancelTitle: "ALERT_CANCEL_BUTTON".localizedAttributed.string,
            buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localizedAttributed.string,
            buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localizedAttributed.string,
            okHandler: { (_) in
                self.navigationController?.popViewController(animated: true)
        }, cancelHandler: { (_) in

        })
        endEditingCodeChars()
    }

    func endEditingCodeChars() {
        for item in codeChars {
            item.endEditing(true)
        }
    }

    @IBAction func onReportDiagnosis(_ sender: Any) {

        view.showLoading()
        var codigoString = ""
        codeChars.forEach {
            let string: String = $0.text ?? ""
            codigoString += string
        }

        diagnosisCodeUseCase?.sendDiagnosisCode(code: codigoString).subscribe(
            onNext: { [weak self] reportedCodeBool in
                self?.view.hideLoading()
                self?.navigateIf(reported: reportedCodeBool)
            }, onError: {  [weak self] error in
                self?.handle(error: error)
                self?.view.hideLoading()
        }).disposed(by: disposeBag)

    }

    private func handle(error: Error) {
        debugPrint("Error sending diagnosis \(error)")
        var errorMessage = "ALERT_MY_HEALTH_CODE_VALIDATION_CONTENT".localized
        var title = "ALERT_MY_HEALTH_CODE_ERROR_CONTENT".localized
        if let diagnosisError = error as? DiagnosisError {
            switch diagnosisError {
            case .apiRejected:
                errorMessage = "ALERT_SHARING_REJECTED_ERROR".localized
            case .idAlreadyUsed:
                errorMessage = "ALERT_ID_ALREADY_USED".localized
            case .wrongId:
                errorMessage = "ALERT_WRONG_ID".localized
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.codeChars.forEach { (char) in
            char.text = "\u{200B}"
            char.layer.cornerRadius = 5
            char.addTarget(self, action: #selector(MyHealthViewController.textFieldDidChange(_:)), for: .editingChanged)
        }

        backButton.isAccessibilityElement = true
        let previous = navigationController?.previousViewController
        if let title = (previous as? AccTitleView)?.accTitle ?? previous?.title {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK_TO".localized + " " + title
        } else {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK".localized
        }
        sendDiagnosticButton.isEnabled = checkSendEnabled()

        setupAccessibility()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        codeTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        sendDiagnosticButton.setTitle("MY_HEALTH_DIAGNOSTIC_CODE_SEND_BUTTON".localized, for: .normal)

    }

    private func setupAccessibility() {
        codeTextField.isAccessibilityElement = true
        codeTextField.accessibilityTraits.insert(UIAccessibilityTraits.allowsDirectInteraction)
        codeTextField.accessibilityLabel = "ACC_DIAGNOSTIC_CODE_FIELD".localized
        codeTextField.accessibilityHint = "ACC_HINT".localized
        codeTextField.keyboardType = .numberPad

        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_MY_DIAGNOSTIC_TITLE".localized

        codigoTitle.isAccessibilityElement = true
        codigoTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        codigoTitle.accessibilityLabel = "ACC_CODE_TITLE".localized

        sendDiagnosticButton.isAccessibilityElement = true
        sendDiagnosticButton.accessibilityLabel = "ACC_BUTTON_SEND_DIAGNOSTIC".localized
        sendDiagnosticButton.accessibilityHint = "ACC_HINT".localized

        if UIAccessibility.isVoiceOverRunning {
            codeTextField.isHidden = false
            codeView.isHidden = true
        } else {
            codeTextField.isHidden = true
            codeView.isHidden = false
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let actualPos = textField.tag

        // if the initial value is an empty string do nothing
        if (textField.text == "\u{200B}") {
            return
        }

        // detect backspace
        if  textField.text == "" || textField.text == nil {
            if   actualPos > 0 && actualPos < self.codeChars.count {
                let prev = codeChars[actualPos - 1]
                prev.becomeFirstResponder()
                prev.text = "\u{200B}"
                textField.text = "\u{200B}"
           }
        }

        // detect new input and pass to the next one
        else if actualPos < self.codeChars.count - 1 {
            // the first character is an unicode empty space
            // so we need to take the second character and assign it to the input
            let finalText = textField.text?.suffix(1)
            textField.text = String(finalText ?? "")
            let next = codeChars[actualPos + 1]
            next.becomeFirstResponder()
        }

        // avoid multiple character in the last input
        if actualPos == self.codeChars.count - 1 {
            let actualText = textField.text ?? "\u{200B}"
            if (actualText != "\u{200B}") {
                let trimmedString = String(actualText.prefix(2))
                let finalString = String(trimmedString.suffix(1))
                textField.text = finalString
            }
        }

        sendDiagnosticButton.isEnabled = checkSendEnabled()
    }

    private func checkSendEnabled() -> Bool {
        codeChars.filter({ $0.text != "\u{200B}" }).count == codeChars.count
    }

    @IBAction func insertCode(_ sender: Any) {
        guard let emptyInput = self.codeChars.filter({ $0.text == "\u{200B}" }).first else {
            self.codeChars.last?.becomeFirstResponder()
            return
        }
        emptyInput.becomeFirstResponder()
    }

    private func navigateIf(reported: Bool) {
        if reported {
            router?.route(to: Routes.myHealthReported, from: self)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (
            notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        // move the root view up by the distance of keyboard height
        DispatchQueue.main.async {
            self.scrollViewBottonConstraint.constant = keyboardSize.height
            self.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height), animated: true)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.scrollViewBottonConstraint.constant = 0
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil {
            guard let textFieldText = textField.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            if count == 12 {
                sendDiagnosticButton.isEnabled = true
            }
            return count <= 12
        }
        return false

    }

}
