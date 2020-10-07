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

class MyHealthViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codigoTitleLabel: UILabel!
    @IBOutlet weak var sendDiagnosticButton: UIButton!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var yearLabel: UILabel!

    var router: AppRouter?
    var diagnosisCodeUseCase: DiagnosisCodeUseCase?
    
    private let emptyText200B: String = "\u{200B}"
    private let disposeBag = DisposeBag()
    private var pickerPresenter: PickerPresenter?
    private let datePicker = UIDatePicker()
    
    private var date : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        backButton.isAccessibilityElement = true
        let previous = navigationController?.previousViewController
        if let title = (previous as? AccTitleView)?.accTitle ?? previous?.title {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK_TO".localized + " " + title
        } else {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK".localized
        }
        setEnableButton(isEnable: false)

        setupAccessibility()
        
        // Open textField
        if UIAccessibility.isVoiceOverRunning {
            self.codeTextField.becomeFirstResponder()
        }
      
        //Reset component
        date = nil
        yearLabel.text = "----"
        monthLabel.text = "--"
        dayLabel.text = "--"
        codeTextField.text = ""
        pickerPresenter?.hiddenPickerView()
    }
    
    @IBAction func onReportDiagnosis(_ sender: Any) {

        view.showLoading()
        let codigoString = self.codeTextField.text ?? ""

        diagnosisCodeUseCase?.sendDiagnosisCode(code: codigoString, date: date ?? Date()).subscribe(
            onNext: { [weak self] reportedCodeBool in
                self?.view.hideLoading()
                self?.navigateIf(reported: reportedCodeBool)
            }, onError: {  [weak self] error in
                self?.handle(error: error)
                self?.view.hideLoading()
        }).disposed(by: disposeBag)
    }
    
   
    
    @objc func doneButtonAction(textView: UITextField) {
        self.view.endEditing(true)
    }
    
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
    }
    
    private func setupAccessibility() {
        
        codeTextField.isAccessibilityElement = true
        codeTextField.accessibilityTraits.insert(UIAccessibilityTraits.allowsDirectInteraction)
        codeTextField.accessibilityLabel = "ACC_MY_HEALTH_CODE_EDIT_TEXT".localized
        codeTextField.accessibilityHint = "ACC_HINT".localized
        codeTextField.keyboardType = .numberPad

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_MY_DIAGNOSTIC_TITLE".localized

        codigoTitleLabel.isAccessibilityElement = true
        codigoTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        codigoTitleLabel.accessibilityLabel = "ACC_CODE_TITLE".localized

        sendDiagnosticButton.isAccessibilityElement = true
        sendDiagnosticButton.accessibilityLabel = "ACC_BUTTON_SEND_DIAGNOSTIC".localized
        sendDiagnosticButton.accessibilityHint = "ACC_HINT".localized

        self.addDoneButtonOnKeyboard(textView: codeTextField)
        
        dayLabel.accessibilityHint = "ACC_HINT".localized
        monthLabel.accessibilityHint = "ACC_HINT".localized
        yearLabel.accessibilityHint = "ACC_HINT".localized
    }
    
    @objc func keyboardWillShow(notification: NSNotification?) {
        guard let keyboardSize = (
                notification?.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        // move the root view up by the distance of keyboard height
        DispatchQueue.main.async {
            self.scrollViewBottonConstraint.constant = keyboardSize.height
            self.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height + CGFloat(70)), animated: true)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification?) {
        // move back the root view origin to zero
        self.scrollViewBottonConstraint.constant = 0
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
   
    private func setEnableButton(isEnable: Bool) {
        sendDiagnosticButton.isEnabled = isEnable
        if isEnable {
            sendDiagnosticButton.titleLabel?.font = UIFont.mainFont(size: .twentytwo, fontType: .bold)
        } else {
            sendDiagnosticButton.titleLabel?.font = UIFont.mainFont(size: .twentytwo, fontType: .regular)
        }
    }
    
    private func addDoneButtonOnKeyboard(textView: UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "SELECTOR_DONE".localized, style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction) )
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textView.inputAccessoryView = doneToolbar
    }
    
   
    @objc private func showDatePicker() {
            pickerPresenter?.openPicker()
    }
    
    private func setupView() {
        
        datePicker.minimumDate = Date().addingTimeInterval(-TimeInterval(14*60*60*24))
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
    
        datePicker.preferredDatePickerStyle = .wheels
        pickerPresenter = PickerPresenter(picker: datePicker, isNeedCancelButton: true)
        pickerPresenter?.delegate = self
        
        dateView.isUserInteractionEnabled = true
        dateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePicker)))
       
        codeTextField.delegate = self
        codeTextField.layer.borderColor = UIColor.purpleApp.cgColor

        dayView.layer.borderColor = UIColor.purpleApp.cgColor
        monthView.layer.borderColor = UIColor.purpleApp.cgColor
        yearView.layer.borderColor = UIColor.purpleApp.cgColor
        
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

    private func navigateIf(reported: Bool) {
        if reported {
            router?.route(to: Routes.myHealthReported, from: self)
        }
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

extension MyHealthViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 12
        let currentString: NSString = (textField.text ?? "") as NSString
        if (string != "\u{232B}"){
            let disallowedCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted
            let replacementStringIsLegal = string.rangeOfCharacter(from: disallowedCharacterSet) == nil
            if !replacementStringIsLegal{
                return false;
            }
        }
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        setEnableButton(isEnable: newString.length >= 12)
        return newString.length <= maxLength
    }
}

extension MyHealthViewController: PickerDelegate {
    
    var cancelHandler: (() -> Void)? {
        onCancel
    }
    
    var containerView: UIView {
        get {
            self.view
        }
    }
    
    func onCancel() {
        date = nil
        yearLabel.text = "----"
        monthLabel.text = "--"
        dayLabel.text = "--"
        
        //Setup accessibility
        dayLabel.accessibilityLabel = "MY_HEALTH_DIAGNOSTIC_DATE_DAY".localized + " " + (dayLabel.text ?? "")
        monthLabel.accessibilityLabel = "MY_HEALTH_DIAGNOSTIC_DATE_MONTH".localized + " " + (monthLabel.text ?? "")
        yearLabel.accessibilityLabel = "MY_HEALTH_DIAGNOSTIC_DATE_YEAR".localized + " " + (yearLabel.text ?? "")
    }
    
    func onDone() {
        date = datePicker.date
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            yearLabel.text = formatter.string(from: date)
            formatter.dateFormat = "MM"
            monthLabel.text = formatter.string(from: date)
            formatter.dateFormat = "dd"
            dayLabel.text = formatter.string(from: date)
            
            //Setup accessibility
            dayLabel.accessibilityLabel = "MY_HEALTH_DIAGNOSTIC_DATE_DAY".localized + " " + (dayLabel.text ?? "")
            monthLabel.accessibilityLabel = "MY_HEALTH_DIAGNOSTIC_DATE_MONTH".localized + " " + (monthLabel.text ?? "")
            yearLabel.accessibilityLabel = "MY_HEALTH_DIAGNOSTIC_DATE_YEAR".localized + " " + (yearLabel.text ?? "")
        }
    }
}
