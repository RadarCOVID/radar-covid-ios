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

class MyHealthStep1ViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customSliderView: CustomSliderView!
    @IBOutlet weak var scrollViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var helperDateLabel: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    
    var router: AppRouter?
    
    private var pickerPresenter: PickerPresenter?
    private let datePicker = UIDatePicker()
    private var date : Date?
    private let maxLengthCode = 12
    private let emptyText200B: String = "\u{200B}"
    private let emptyText232B: String = "\u{232B}"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAccessibility()
        
        // Open textField
        if UIAccessibility.isVoiceOverRunning {
            self.codeTextField.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIAccessibility.post(notification: .screenChanged, argument: self.codeTextField)
            }
        }
    }
    
    private func setupView() {
        setEnableButton(isEnable: false)
        
        self.title = "MY_HEALTH_TITLE_STEP1".localized
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.twilight.cgColor
        
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        continueButton.setTitle("ACC_BUTTON_CONTINUE".localized, for: .normal)
        
        datePicker.minimumDate = Date().addingTimeInterval(-TimeInterval(14*60*60*24))
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
    
        datePicker.preferredDatePickerStyle = .wheels
        pickerPresenter = PickerPresenter(picker: datePicker, isNeedCancelButton: true)
        pickerPresenter?.delegate = self
        
        dateView.isUserInteractionEnabled = true
        dateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePicker)))
       
        codeTextField.delegate = self
        codeTextField.layer.borderColor = UIColor.twilight.cgColor

        dayView.layer.borderColor = UIColor.twilight.cgColor
        monthView.layer.borderColor = UIColor.twilight.cgColor
        yearView.layer.borderColor = UIColor.twilight.cgColor
        
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
        
        addDoneButtonOnKeyboard(textView: codeTextField)
        
        customSliderView.configure(indexStep: 1, totalStep: 2)
    }
    
    private func setupAccessibility() {
        
        codeTextField.isAccessibilityElement = true
        codeTextField.accessibilityTraits.insert(UIAccessibilityTraits.allowsDirectInteraction)
        codeTextField.accessibilityLabel = "ACC_MY_HEALTH_CODE_EDIT_TEXT".localized
        codeTextField.accessibilityHint = "ACC_HINT".localized
        codeTextField.keyboardType = .numberPad
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        
        continueButton.isAccessibilityElement = true
        continueButton.accessibilityLabel = "ACC_BUTTON_ALERT_CONTINUE".localized
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityLabel = "ACC_BUTTON_ALERT_CANCEL".localized
        
        dateView.isAccessibilityElement = true
        dateView.accessibilityLabel = "ACC_MY_HEALTH_DATE_PICKER_NO_SELECTED".localized
        dateView.accessibilityHint = "ACC_HINT".localized
        
        datePicker.accessibilityLabel = "ACC_MY_HEALTH_DATE_PICKER_SHOW".localized
    }
    
    private func setEnableButton(isEnable: Bool) {
        continueButton.isEnabled = isEnable
        if isEnable {
            continueButton.titleLabel?.font = UIFont.mainFont(size: .twentytwo, fontType: .bold)
        } else {
            continueButton.titleLabel?.font = UIFont.mainFont(size: .twentytwo, fontType: .regular)
        }
    }
    
    @objc private func showDatePicker() {
        self.view.endEditing(true)

        pickerPresenter?.openPicker()
        UIAccessibility.post(notification: .layoutChanged, argument: self.datePicker)
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
            self.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height + CGFloat(70)), animated: false)
            self.pickerPresenter?.hiddenPickerView()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification?) {
        // move back the root view origin to zero
        DispatchQueue.main.async {
            self.scrollViewBottonConstraint.constant = 20
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    @objc func doneButtonAction(textView: UITextField) {
        self.view.endEditing(true)
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
    
    @IBAction func onBack(_ sender: Any) {
        self.router?.pop(from: self, animated: true)
    }
    
    @IBAction func onContinue(_ sender: Any) {
        self.router?.route(to: Routes.myHealthStep2, from: self, parameters: self.codeTextField.text, date)
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
}

extension MyHealthStep1ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = (textField.text ?? "") as NSString
        
        if (string != emptyText232B) {
            let disallowedCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted
            let replacementStringIsLegal = string.rangeOfCharacter(from: disallowedCharacterSet) == nil
            if !replacementStringIsLegal{
                return false;
            }
        }
        
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        setEnableButton(isEnable: newString.length >= maxLengthCode)
        return newString.length <= maxLengthCode
    }
}

extension MyHealthStep1ViewController: PickerDelegate {
    
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
        
        dateView.accessibilityLabel = "ACC_MY_HEALTH_DATE_PICKER_NO_SELECTED".localized
        
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
            let daySelected: String = "MY_HEALTH_DIAGNOSTIC_DATE_DAY".localized + " " + (dayLabel.text ?? "")
            let monthSelected: String = "MY_HEALTH_DIAGNOSTIC_DATE_MONTH".localized + " " + (monthLabel.text ?? "")
            let yearSelected: String = "MY_HEALTH_DIAGNOSTIC_DATE_YEAR".localized + " " + (yearLabel.text ?? "")

            dateView.accessibilityLabel = "ACC_MY_HEALTH_DATE_PICKER_SELECTED".localized.replacingOccurrences(of: "$1", with: daySelected + " " + monthSelected + " " + yearSelected)
        }
    }
}
