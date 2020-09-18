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

    private let disposeBag = DisposeBag()

    private let bgImageRed = UIImage(named: "GradientBackgroundRed")
    private let bgImageOrange = UIImage(named: "GradientBackgroundOrange")

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var whatToDoTitle: UILabel!
    @IBOutlet weak var youCouldBe: UILabel!
    @IBOutlet weak var infectedText: UILabel!
    @IBOutlet weak var phoneView: BackgroundView!
    @IBOutlet weak var timeTableLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var covidWeb: UILabel!

    @IBOutlet weak var phoneViewVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneViewHiddenConstraint: NSLayoutConstraint!

    @IBOutlet weak var selectorView: BackgroundView!
    @IBOutlet weak var caSelectorButton: UIButton!
    @IBOutlet weak var otherSympthoms: UILabel!
    @IBOutlet weak var howAct: UILabel!

    private var currentCA: CaData?

    var ccaUseCase: CCAAUseCase!
    var ccaArray: [CaData]?

    var since: Date?

    private var pickerPresenter: PickerPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
        let picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        pickerPresenter = PickerPresenter(picker: picker)
        pickerPresenter?.delegate = self

        otherSympthoms.isUserInteractionEnabled = true
        howAct.isUserInteractionEnabled = true
        expositionBGView.image = bgImageOrange

        phoneView.isUserInteractionEnabled = true
        self.covidWeb.isUserInteractionEnabled = true
        self.covidWeb.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                           action: #selector(userDidTapWeb(tapGestureRecognizer:))))

        self.phoneLabel.isUserInteractionEnabled = true
        self.phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                             action: #selector(onCallTap(tapGestureRecognizer:))))
        otherSympthoms.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                            action: #selector(userDidTapOtherSympthoms(tapGestureRecognizer:))))
        howAct.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                    action: #selector(userDidTapHowAct(tapGestureRecognizer:))))

        phoneView.image = UIImage(named: "WhiteCard")

        caSelectorButton.setTitle("LOCALE_SELECTION_REGION_DEFAULT".localized, for: .normal)
        self.setCaSelector()

    }

    func setupAccessibility() {
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_HIGH_EXPOSED_TITLE".localized

        whatToDoTitle.isAccessibilityElement = true
        whatToDoTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoTitle.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentCA = ccaUseCase.getCurrent()
        setInfectedText()
    }

    @objc func userDidTapWeb(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: currentCA?.web)
    }

    func setInfectedText() {
        let date = self.since ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        let actualizado = formatter.string(from: date)
        var daysSinceLastInfection = Date().days(sinceDate: since ?? Date()) ?? 1
        if daysSinceLastInfection == 0 {
            daysSinceLastInfection = 1
        }
        youCouldBe.font = UIFont(name: "Helvetica Neue", size: 20)
        youCouldBe.attributedText = "EXPOSITION_HIGH_DESCRIPTION"
            .localizedAttributed(withParams: [String(daysSinceLastInfection), actualizado])
    }

    @objc func onCallTap(tapGestureRecognizer: UITapGestureRecognizer) {
        open(phone: currentCA?.phone ?? "CONTACT_PHONE".localized)
    }

    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "EXPOSURE_HIGH_INFO_URL".localized)
    }

    func setCaSelector() {
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
        self.covidWeb.text = currentCa.webName ?? currentCa.web ?? ""
        let title = currentCa.description ?? "LOCALE_SELECTION_REGION_DEFAULT".localized
        self.caSelectorButton.setTitle(title, for: .normal)
    }

    @IBAction func caaSelectAction(_ sender: Any) {
        pickerPresenter!.openPicker()
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

    @objc func userDidTapOtherSympthoms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_OTHER_SYMPTOMS_URL".localized)
    }

    @objc func userDidTapHowAct(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_SYMPTOMS_WHAT_TO_DO_URL".localized)
    }

}
