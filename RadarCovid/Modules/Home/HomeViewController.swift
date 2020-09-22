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
import DP3TSDK

class HomeViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var topRadarTitle: NSLayoutConstraint!
    @IBOutlet weak var topActiveNotificationConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var envLabel: UILabel!
    @IBOutlet weak var defaultImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var expositionTitleLabel: UILabel!
    @IBOutlet weak var expositionDescriptionLabel: UILabel!
    @IBOutlet weak var expositionView: BackgroundView!
    @IBOutlet weak var radarSwitch: UISwitch!
    @IBOutlet weak var radarMessageLabel: UILabel!
    @IBOutlet weak var radarTitleLabel: UILabel!
    @IBOutlet weak var radarView: BackgroundView!
    @IBOutlet weak var topComunicationConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomComunicationConstraint: NSLayoutConstraint!
    @IBOutlet weak var communicationButton: UIButton!
    @IBOutlet weak var activateNotificationButton: UIButton!
    @IBOutlet weak var notificationInactiveMessageLabel: UILabel!
    @IBOutlet weak var resetDataButton: UIButton!
    @IBOutlet weak var expositionDetailImage: UIImageView!
    var termsRepository: TermsAcceptedRepository!
    @IBOutlet weak var btnShare: UIButton!
    
    private let bgImageRed = UIImage(named: "GradientBackgroundRed")
    private let bgImageOrange = UIImage(named: "GradientBackgroundOrange")
    private let bgImageGreen = UIImage(named: "GradientBackgroundGreen")
    private let imageHomeGray = UIImage(named: "imageHome")?.grayScale
    private let imageHome = UIImage(named: "imageHome")
    private let circle = UIImage(named: "circle")
    private let circleGray = UIImage(named: "circle")?.grayScale

    var errorHandler: ErrorHandler!
    var router: AppRouter?
    var viewModel: HomeViewModel?

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
        setupBindings()
        setupUserInteraction()
        setupView()
        
        if !termsRepository.termsAccepted {
            router?.route(to: .termsUpdated, from: self, parameters: nil)
        }
        
        viewModel?.checkInitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.checkShowBackToHealthyDialog()
        viewModel?.checkRadarStatus()
    }
    
    @IBAction func onShare(_ sender: Any) {
        router?.route(to: .shareApp, from: self)
    }
    
    @IBAction func onReset(_ sender: Any) {

        showAlertCancelContinue(
            title: "ALERT_HOME_RESET_TITLE".localizedAttributed,
            message: "ALERT_HOME_RESET_CONTENT".localizedAttributed,
            buttonOkTitle: "ALERT_ACCEPT_BUTTON".localized,
            buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
            buttonOkVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized,
            buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized
        ) { [weak self] () in
            self?.viewModel!.heplerQAReset()
        }
    }

    @IBAction func onCommunicate(_ sender: Any) {
        guard let expositionInfo = try? viewModel!.expositionInfo.value() else {
            return
        }
        
        if radarSwitch.isOn {
            if expositionInfo.level == .infected {
                router!.route(to: Routes.myHealthReported, from: self)
            } else {
                router!.route(to: Routes.myHealthStep0, from: self)
            }
        } else {
            showAlertOk(
                title: "",
                message: "ALERT_RADAR_REQUIRED_TO_REPORT".localized,
                buttonTitle: "ALERT_ACCEPT_BUTTON".localized
            )
        }
    }
    
    @IBAction func onOpenSettingsTap(_ sender: Any) {
        showActivationMessage()
    }

    @IBAction func onRadarSwitchChange(_ sender: Any) {
        let active = radarSwitch.isOn

        if active {
            viewModel!.changeRadarStatus(true)
            radarSwitch.accessibilityHint = "ACC_BUTTON_DEACTIVATE_RADAR".localized
        } else {
            
            self.showAlertCancelContinue(
                title: "ALERT_HOME_RADAR_TITLE".localizedAttributed(),
                message: "ALERT_HOME_RADAR_CONTENT".localizedAttributed(),
                buttonOkTitle: "ALERT_HOME_RADAR_CANCEL_BUTTON".localized,
                buttonCancelTitle: "ALERT_HOME_RADAR_OK_BUTTON".localized,
                buttonOkVoiceover: "ACC_BUTTON_RADAR_CANCEL".localized,
                buttonCancelVoiceover: "ACC_BUTTON_RADAR_OK".localized,
                okHandler: { [weak self] in
                    self?.radarSwitch.isOn = true
                }, cancelHandler: { [weak self] in
                    self?.radarSwitch.accessibilityHint = "ACC_BUTTON_ACTIVATE_RADAR".localized
                    self?.viewModel?.changeRadarStatus(false)
            })
        }
    }

    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_MORE_INFO".localized.getUrlFromHref())
    }
    
    @objc func onExpositionTap() {
        if let level =  try? viewModel?.expositionInfo.value() {
            navigateToDetail(level)
        }
    }
    
    private func setupAccessibility() {
        radarSwitch.isAccessibilityElement = true

        expositionTitleLabel.isAccessibilityElement = true
        expositionTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)
        expositionTitleLabel.accessibilityHint = "ACC_HINT".localized

        moreInfoLabel.isAccessibilityElement = true
        moreInfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoLabel.accessibilityLabel = "EXPOSITION_HIGH_MORE_INFO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoLabel.accessibilityHint = "ACC_HINT".localized
        
        expositionDetailImage.isAccessibilityElement = false
        expositionDetailImage.accessibilityLabel = "ACC_BUTTON_NAVIGATE_TO_EXPOSITION".localized
        expositionDetailImage.accessibilityTraits.insert(UIAccessibilityTraits.button)
        expositionDetailImage.accessibilityHint = "ACC_HINT".localized

        notificationInactiveMessageLabel.isAccessibilityElement = true
        notificationInactiveMessageLabel.accessibilityHint = "ACC_HINT".localized
        notificationInactiveMessageLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)
        
        btnShare.isAccessibilityElement = true
        btnShare.accessibilityLabel = "SHARE_LINK_DOWNLOAD".localized
        btnShare.accessibilityHint = "ACC_HINT".localized
        btnShare.accessibilityTraits.insert(UIAccessibilityTraits.button)
        
        communicationButton.isAccessibilityElement = true
        communicationButton.accessibilityHint = "ACC_HINT".localized
        communicationButton.accessibilityTraits.insert(UIAccessibilityTraits.button)

        activateNotificationButton.isAccessibilityElement = false
    }
    
    private func setupBindings() {

        viewModel!.radarStatus.subscribe { [weak self] status in
            self?.changeRadarMessage(status: status.element ?? .inactive)
        }.disposed(by: disposeBag)

        viewModel!.expositionInfo.subscribe { [weak self] exposition in
            self?.updateExpositionInfo(exposition.element)
        }.disposed(by: disposeBag)

        viewModel!.error.subscribe { [weak self] error in
            self?.errorHandler?.handle(error: error.element)
        }.disposed(by: disposeBag)

        viewModel!.alertMessage.subscribe { [weak self] message in
            self?.showAlert(message: message.element)
        }.disposed(by: disposeBag)

        viewModel!.checkState.subscribe { [weak self] showCheck in
            self?.showCheckState(showCheck.element)
        }.disposed(by: disposeBag)

        viewModel!.errorState.subscribe { [weak self] error in
            self?.setErrorState(error.element ?? nil)
        }.disposed(by: disposeBag)

        viewModel!.showBackToHealthyDialog.subscribe { [weak self] expositionCheck in
            if expositionCheck.element ?? false {
                self?.showTimeExposed()
            }
        }.disposed(by: disposeBag)
    }
    
    private func setupView() {
        communicationButton.setTitle("HOME_BUTTON_SEND_POSITIVE".localized, for: .normal)
        communicationButton.titleLabel?.textAlignment = .center
        communicationButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        radarView.image = UIImage(named: "WhiteCard")

        radarSwitch.tintColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        radarSwitch.layer.cornerRadius = radarSwitch.frame.height / 2
        radarSwitch.backgroundColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)

        if Config.environment == "PRE" {
            envLabel.isHidden = false
            resetDataButton.isHidden = false
            
            let bundleVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] ?? "") as! String
            envLabel.text = "\(Config.environment) - V_\(Config.version)_\(bundleVersion)"
            
            self.envLabel.isUserInteractionEnabled = true
            self.envLabel.isAccessibilityElement = true
            let tapGestureHeplerQAChangeHealthy = UITapGestureRecognizer(target: self, action: #selector(self.heplerQAChangeHealthy))
            self.envLabel.addGestureRecognizer(tapGestureHeplerQAChangeHealthy)
            
            
            self.defaultImage.isUserInteractionEnabled = true
            self.defaultImage.isAccessibilityElement = true
            let tapGestureHeplerQAShowAlert = UITapGestureRecognizer(target: self, action: #selector(self.heplerQAShowAlert))
            self.defaultImage.addGestureRecognizer(tapGestureHeplerQAShowAlert)
        } else {
            resetDataButton.isHidden = true
            envLabel.isHidden = true
        }
        
        viewModel?.checkOnboarding()

        errorHandler!.alertDelegate = self
    }
    
    private func setupUserInteraction() {
        moreInfoLabel.isUserInteractionEnabled = true
        moreInfoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                      action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))

        expositionView.isUserInteractionEnabled = true
        expositionView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                            action: #selector(self.onExpositionTap)))

        notificationInactiveMessageLabel.isUserInteractionEnabled = true
        notificationInactiveMessageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(self.onOpenSettingsTap)))
    }
    
    private func showTimeExposed() {
        router?.route(to: .timeExposed, from: self, parameters: nil)
    }

    private func updateExpositionInfo(_ exposition: ExpositionInfo?) {
        guard let exposition = exposition else {
            return
        }
        switch exposition.level {
        case .exposed:
            setExposed(since: exposition.since ?? Date())
        case .healthy:
            setHealthy()
        case .infected:
            setInfected()
        case .unknown:
            break
        }
    }

    private func setExposed(since: Date) {
       
        expositionTitleLabel.text = "HOME_EXPOSITION_TITLE_HIGH".localized
        let remindingDays = self.viewModel?.checkRemindingExpositionDays(since: since)
        let remindingDaysText =
            remindingDays ?? 0 <= 1
                ? "HOME_EXPOSITION_COUNT_ONE_DAY".localizedAttributed(withParams: [String(remindingDays ?? 0)])
                : "HOME_EXPOSITION_COUNT_ANYMORE".localizedAttributed(withParams: [String(remindingDays ?? 0)])
        let attributedText = NSMutableAttributedString.init(attributedString: "HOME_EXPOSITION_MESSAGE_HIGH".localizedAttributed(
                withParams: ["CONTACT_PHONE".localized]
            )
        )
        attributedText
            .append(remindingDaysText)
        expositionDescriptionLabel.attributedText = attributedText
        expositionDescriptionLabel.setMagnifierFontSize()
        expositionView.image = bgImageOrange
        communicationButton.isHidden = false
        topComunicationConstraint.constant = 10
        moreInfoLabel.isHidden = true
        radarSwitch.isHidden = false
    }
    
   
    
    private func setHealthy() {
        expositionTitleLabel.text = "HOME_EXPOSITION_TITLE_LOW".localized
        expositionDescriptionLabel.locKey  = "HOME_EXPOSITION_MESSAGE_LOW"

        expositionView.image = bgImageGreen
        communicationButton.isHidden = false
        topComunicationConstraint.constant = 10
        moreInfoLabel.isHidden = true
        radarSwitch.isHidden = false
    }

    private func setInfected() {
        expositionTitleLabel.text = "HOME_EXPOSITION_TITLE_POSITIVE".localized
        expositionDescriptionLabel.locKey = "HOME_EXPOSITION_MESSAGE_INFECTED"

        expositionView.image = bgImageRed
        communicationButton.isHidden = true
        topComunicationConstraint.constant = -(communicationButton.frame.size.height + bottomComunicationConstraint.constant)
        moreInfoLabel.isHidden = false
        radarSwitch.isHidden = true
    }

    private func setImagesInactive(_ inactive: Bool) {
        if inactive {
            defaultImage.image = imageHomeGray
            circleImage.image = circleGray
        } else {
            defaultImage.image = imageHome
            circleImage.image = circle
        }
    }

    private func setErrorState(_ error: DomainError?) {

        if let error = error {
            switch error {
            case .bluetoothTurnedOff:
                changeRadarMessage(status: .inactive)
                notificationInactiveMessageLabel.text = "HOME_BLUETOOTH_INACTIVE_MESSAGE".localized
                showExtraMessage()
                activateNotificationButton.isHidden = true
            case .notAuthorized:
                changeRadarMessage(status: .inactive)
                notificationInactiveMessageLabel.text = "HOME_NOTIFICATION_INACTIVE_MESSAGE".localized
                activateNotificationButton.isHidden = false
                showExtraMessage()
            case .unexpected:
               break
            }
        } else {
            // Clean error state
            hideExtraMessage()
        }
    }
    
    private func changeRadarMessage(status: RadarStatus) {

        switch status {
        case .active:
            radarTitleLabel.text = "HOME_RADAR_TITLE_ACTIVE".localized
            radarMessageLabel.text = "HOME_RADAR_CONTENT_ACTIVE".localized
            radarMessageLabel.textColor = UIColor.black
            radarSwitch.isOn = true
            radarSwitch.accessibilityHint = "ACC_BUTTON_DEACTIVATE_RADAR".localized
            setImagesInactive(false)
        case .inactive:
            radarTitleLabel.text = "HOME_RADAR_TITLE_INACTIVE".localized
            radarMessageLabel.text = "HOME_RADAR_CONTENT_INACTIVE".localized
            radarMessageLabel.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
            radarSwitch.isOn = false
            radarSwitch.accessibilityHint = "ACC_BUTTON_ACTIVATE_RADAR".localized
            setImagesInactive(true)
        case .disabled:
            radarTitleLabel.text = "HOME_RADAR_TITLE_INACTIVE".localized
            radarMessageLabel.text = "HOME_RADAR_MESSAGE_DISABLED".localized
            radarMessageLabel.textColor = UIColor.black
            radarSwitch.isOn = false

            radarSwitch.accessibilityHint = ""
            radarSwitch.isHidden = true
            setImagesInactive(false)
        }
    }

    private func showExtraMessage() {
        topActiveNotificationConstraint.priority = .defaultHigh
        topRadarTitle.priority = .defaultLow
        notificationInactiveMessageLabel.isHidden = false
        activateNotificationButton.isHidden = false
        radarSwitch.isOn = false
    }
    
    private func hideExtraMessage() {
        topActiveNotificationConstraint.priority = .defaultLow
        topRadarTitle.priority = .defaultHigh
        notificationInactiveMessageLabel.isHidden = true
        activateNotificationButton.isHidden = true
        radarSwitch.isEnabled = true
    }

    private func showError(message: String?) {
        if let message = message {
            showAlertOk(
                title: "ALERT_GENERIC_ERROR_TITLE".localized,
                message: message, buttonTitle: "ALERT_ACCEPT_BUTTON".localized
            )
        }
    }

    private func showAlert(message: String?) {
        if let message = message {
            showAlertOk(
                title: "MESSAGE_POPUP".localized,
                message: message, buttonTitle: "ALERT_ACCEPT_BUTTON".localized
            )
        }
    }

    private func showCheckState(_ showCheck: Bool?) {
        let showCheck = showCheck ?? false
        checkImage.isHidden = !showCheck
        defaultImage.isHidden = showCheck
    }
    
    private func navigateToDetail(_ info: ExpositionInfo) {
        switch info.level {
        case .healthy:
            router?.route(to: Routes.healthyExposition, from: self, parameters: info.lastCheck)
        case .exposed:
            router?.route(to: Routes.highExposition, from: self, parameters: info.since)
        case .infected:
            router?.route(to: Routes.positiveExposed, from: self, parameters: info.since)
        }
    }
    
    private func showActivationMessage() {
        self.showAlertOk(
            title: "ALERT_HOME_COVID_NOTIFICATION_TITLE".localized,
            message: "HOME_COVID_NOTIFICATION_POPUP_INACTIVE".localized,
            buttonTitle: "ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized
            ) { 
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    @objc private func heplerQAChangeHealthy() {
        self.viewModel?.heplerQAChangeHealthy()
    }
    
    @objc private func heplerQAShowAlert() {
        showTimeExposed()
    }
}

extension HomeViewController: AccTitleView {

    var accTitle: String? {
        get {
            "ACC_HOME_TITLE".localized
        }
    }
}
