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

class HighExpositionViewController: BaseExposed {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var whatToDoTitleLabel: UILabel!
    @IBOutlet weak var youCouldBeLabel: UILabel!
    @IBOutlet weak var phoneView: BackgroundView!
    @IBOutlet weak var timeTableLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var covidWebLabel: UILabel!

    @IBOutlet weak var phoneViewVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneViewHiddenConstraint: NSLayoutConstraint!

    @IBOutlet weak var selectorView: BackgroundView!
    @IBOutlet weak var caSelectorLabel: UILabel!
    @IBOutlet weak var caSelectorButton: UIButton!
    @IBOutlet weak var otherSympthomsLabel: UILabel!
    @IBOutlet weak var howActLabel: UILabel!
    
    var ccaUseCase: CCAAUseCase!
    var since: Date?
    private var ccaArray: [CaData]?
    private var currentCA: CaData?
    
    private var pickerPresenter: PickerPresenter?
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
      
        return picker
    }()
    
    private let bgImageRed = UIImage(named: "GradientBackgroundRed")
    private let bgImageOrange = UIImage(named: "GradientBackgroundOrange")
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentCA = ccaUseCase.getCurrent()
        
        setupView()
        setupAccessibility()

        setCaSelector()
    }
    
    @IBAction func caaSelectAction(_ sender: Any) {
        UIAccessibility.post(notification: .layoutChanged, argument: self.picker)
        pickerPresenter!.openPicker()
    }
    
    @objc func userDidTapOtherSympthoms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_OTHER_SYMPTOMS".localized.getUrlFromHref())
    }

    @objc func userDidTapHowAct(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_SYMPTOMS_WHAT_TO_DO".localized.getUrlFromHref())
    }
    
    @objc func onCallTap(tapGestureRecognizer: UITapGestureRecognizer) {
        open(phone: currentCA?.phone ?? "CONTACT_PHONE".localized)
    }

    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MORE_INFO_EXPOSURE_HIGH".localized.getUrlFromHref())
    }
    
    @objc func userDidTapWeb(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: currentCA?.web)
    }
    
    private func setupAccessibility() {
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = "ACC_HIGH_EXPOSED_TITLE".localized

        whatToDoTitleLabel.isAccessibilityElement = true
        whatToDoTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoTitleLabel.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
        
        otherSympthomsLabel.isAccessibilityElement = true
        otherSympthomsLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        otherSympthomsLabel.accessibilityLabel = "EXPOSITION_HIGH_OTHER_SYMPTOMS".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        otherSympthomsLabel.accessibilityHint = "ACC_HINT".localized
        
        moreInfoView.isAccessibilityElement = true
        moreInfoView.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoView.accessibilityLabel = "MORE_INFO_EXPOSURE_HIGH".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoView.accessibilityHint = "ACC_HINT".localized
        
        howActLabel.isAccessibilityElement = true
        howActLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        howActLabel.accessibilityLabel = "EXPOSITION_HIGH_SYMPTOMS_WHAT_TO_DO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        howActLabel.accessibilityHint = "ACC_HINT".localized
        
        phoneLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)
        phoneLabel.accessibilityHint = "ACC_HINT".localized
        
        covidWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        covidWebLabel.accessibilityHint = "ACC_HINT".localized
        
        caSelectorButton.accessibilityHint = "ACC_HINT".localized
        caSelectorButton.accessibilityLabel = self.caSelectorLabel.text
    }
    
    private func setupView() {

        pickerPresenter = PickerPresenter(picker: picker)
        pickerPresenter?.delegate = self

        otherSympthomsLabel.isUserInteractionEnabled = true
        howActLabel.isUserInteractionEnabled = true
        expositionBGView.image = bgImageOrange

        phoneView.isUserInteractionEnabled = true
        self.covidWebLabel.isUserInteractionEnabled = true
        self.covidWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                           action: #selector(userDidTapWeb(tapGestureRecognizer:))))

        self.phoneLabel.isUserInteractionEnabled = true
        self.phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                             action: #selector(onCallTap(tapGestureRecognizer:))))
        otherSympthomsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                            action: #selector(userDidTapOtherSympthoms(tapGestureRecognizer:))))
        howActLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                    action: #selector(userDidTapHowAct(tapGestureRecognizer:))))

        phoneView.image = UIImage(named: "WhiteCard")

        //Text Infect
        let date = self.since ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        let actualizado = formatter.string(from: date)
        var daysSinceLastInfection = Date().days(sinceDate: since ?? Date()) ?? 1
        if daysSinceLastInfection == 0 {
            daysSinceLastInfection = 1
        }
        youCouldBeLabel.attributedText = "EXPOSITION_HIGH_DESCRIPTION"
            .localizedAttributed(withParams: [String(daysSinceLastInfection), actualizado])
        
        caSelectorLabel.text = "LOCALE_SELECTION_REGION_DEFAULT".localized
        caSelectorButton.layer.cornerRadius = 8
        caSelectorButton.layer.borderWidth = 1
        caSelectorButton.layer.borderColor = UIColor.deepLilac.cgColor
    }
    
    private func setCaSelector() {
        
        self.selectorView.image = UIImage.init(named: "WhiteCard")
        self.selectorView.isUserInteractionEnabled = true

        self.ccaUseCase.getCCAA().subscribe(onNext: { (data) in
            self.ccaArray = data
        }, onError: { (err) in
            print(err)
            self.ccaArray = []
        }).disposed(by: disposeBag)

        guard let currentCa = self.ccaUseCase.getCurrent() else {
            self.phoneView.isHidden = true
            self.phoneViewHiddenConstraint.priority = .defaultHigh
            self.phoneViewVisibleConstraint.priority = .defaultLow
            return
        }
        
        var temporallyCcaArray: [CaData] = []
        temporallyCcaArray.append(currentCa)
        temporallyCcaArray += (self.ccaArray ?? []).filter { $0.id != currentCa.id }
        
        self.ccaArray = temporallyCcaArray
        self.phoneViewHiddenConstraint.priority = .defaultLow
        self.phoneViewVisibleConstraint.priority = .defaultHigh
        self.phoneView.isHidden = false
        self.phoneLabel.text = currentCa.phone ?? "CONTACT_PHONE".localized
        self.covidWebLabel.text = currentCa.webName ?? currentCa.web ?? ""
        
        let title = currentCa.description ?? "LOCALE_SELECTION_REGION_DEFAULT".localized
        self.caSelectorLabel.text = title
        caSelectorButton.accessibilityLabel = title
    }
}

extension HighExpositionViewController: UIPickerViewDelegate, UIPickerViewDataSource, PickerDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ccaArray?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ccaArray?[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentCa =  self.ccaArray?[row] ?? self.ccaArray?.first else {
            return
        }
        ccaUseCase.setCurrent(cca: currentCa)
        self.currentCA = currentCa
    }
    var containerView: UIView {
        get {
            view
        }
    }

    func onDone() {
        guard ccaUseCase.getCurrent() != nil else {
            // if not current then we need to select the first that was selected
            guard let firstca = self.ccaArray?.first else {
                setCaSelector()
                return
            }
            ccaUseCase.setCurrent(cca: firstca)
            setCaSelector()
            return
        }
        setCaSelector()
    }
    
    func onCancel() {
        //Nothing to do here
    }
}
