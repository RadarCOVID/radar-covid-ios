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

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
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
            self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
                TermsView.initWithParentViewController(viewController: self, delegate: self)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel!.checkShowBackToHealthyDialog()
        viewModel!.restoreLastStateAndSync()
    }
    
    @IBAction func onReset(_ sender: Any) {

        showAlertCancelContinue(
            title: "ALERT_HOME_RESET_TITLE".localized,
            message: "ALERT_HOME_RESET_CONTENT".localized,
            buttonOkTitle: "ALERT_OK_BUTTON".localized,
            buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
            buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localized,
            buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized
        ) { [weak self] (_) in
            self?.viewModel!.reset()
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
                buttonTitle: "ALERT_ACCEPT_BUTTON".localized,
                buttonVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized
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
        } else {
            self.showAlertCancelContinue(
                title: "ALERT_HOME_RADAR_TITLE".localized,
                message: "ALERT_HOME_RADAR_CONTENT".localized,
                buttonOkTitle: "ALERT_HOME_RADAR_CANCEL_BUTTON".localized,
                buttonCancelTitle: "ALERT_HOME_RADAR_OK_BUTTON".localized,
                buttonOkVoiceover: "ACC_BUTTON_RADAR_CANCEL".localized,
                buttonCancelVoiceover: "ACC_BUTTON_RADAR_OK".localized,
                okHandler: { [weak self] _ in
                    self?.radarSwitch.isOn = true
                }, cancelHandler: { [weak self] _ in
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

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        titleLabel.accessibilityLabel = "ACC_HOME_TITLE".localized

        expositionTitleLabel.isAccessibilityElement = true
        expositionTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)
        expositionTitleLabel.accessibilityHint = "ACC_HINT".localized

        moreInfoLabel.isAccessibilityElement = true
        moreInfoLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoLabel.accessibilityLabel = "EXPOSITION_HIGH_MORE_INFO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoLabel.accessibilityHint = "ACC_HINT".localized
        
        titleLabel.isHidden = !UIAccessibility.isVoiceOverRunning

        expositionDetailImage.isAccessibilityElement = false
        expositionDetailImage.accessibilityLabel = "ACC_BUTTON_NAVIGATE_TO_EXPOSITION".localized
        expositionDetailImage.accessibilityTraits.insert(UIAccessibilityTraits.button)
        expositionDetailImage.accessibilityHint = "ACC_HINT".localized

        notificationInactiveMessageLabel.isAccessibilityElement = true
        notificationInactiveMessageLabel.accessibilityHint = "ACC_HINT".localized
        notificationInactiveMessageLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)

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

        radarView.image = UIImage(named: "WhiteCard")

        radarSwitch.tintColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        radarSwitch.layer.cornerRadius = radarSwitch.frame.height / 2
        radarSwitch.backgroundColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)

        resetDataButton.isHidden = !Config.debug
        envLabel.isHidden = !Config.debug
        
        if Config.debug {
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
        }

        viewModel!.checkInitialExposition()
        viewModel!.checkOnboarding()

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
        dissableAccesibility(isDissable: true)
        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            TimeExposedView.initWithParentViewController(viewController: self, delegate: self)
        }
    }

    private func updateExpositionInfo(_ exposition: ExpositionInfo?) {
        guard let exposition = exposition else {
            return
        }
        switch exposition.level {
        case .exposed:
            setExposed()
        case .healthy:
            setHealthy()
        case .infected:
            setInfected()
        }
    }

    private func setExposed() {
        expositionTitleLabel.text = "HOME_EXPOSITION_TITLE_HIGH".localized
        expositionDescriptionLabel.attributedText = "HOME_EXPOSITION_MESSAGE_HIGH".localizedAttributed(
            withParams: ["CONTACT_PHONE".localized]
        )
        expositionView.image = bgImageOrange
        expositionTitleLabel.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        communicationButton.isHidden = false
        topComunicationConstraint.constant = 10
        moreInfoLabel.isHidden = true
    }
    
    private func setHealthy() {
        expositionTitleLabel.text = "HOME_EXPOSITION_TITLE_LOW".localized
        expositionDescriptionLabel.locKey  = "HOME_EXPOSITION_MESSAGE_LOW"
        expositionView.image = bgImageGreen
        expositionTitleLabel.textColor = #colorLiteral(red: 0.3449999988, green: 0.6899999976, blue: 0.4160000086, alpha: 1)
        communicationButton.isHidden = false
        topComunicationConstraint.constant = 10
        moreInfoLabel.isHidden = true
    }

    private func setInfected() {
        expositionTitleLabel.text = "HOME_EXPOSITION_TITLE_POSITIVE".localized
        expositionDescriptionLabel.locKey = "HOME_EXPOSITION_MESSAGE_INFECTED"
        expositionView.image = bgImageRed
        expositionTitleLabel.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        communicationButton.isHidden = true
        topComunicationConstraint.constant = -(communicationButton.frame.size.height + bottomComunicationConstraint.constant)
        moreInfoLabel.isHidden = false
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
            radarSwitch.accessibilityLabel = "ACC_BUTTON_DEACTIVATE_RADAR".localized
            setImagesInactive(false)
        case .inactive:
            radarTitleLabel.text = "HOME_RADAR_TITLE_INACTIVE".localized
            radarMessageLabel.text = "HOME_RADAR_CONTENT_INACTIVE".localized
            radarMessageLabel.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
            radarSwitch.isOn = false
            radarSwitch.accessibilityLabel = "ACC_BUTTON_ACTIVATE_RADAR".localized
            setImagesInactive(true)
        case .disabled:
            radarTitleLabel.text = "HOME_RADAR_TITLE_INACTIVE".localized
            radarMessageLabel.text = "HOME_RADAR_MESSAGE_DISABLED".localized
            radarMessageLabel.textColor = UIColor.black
            radarSwitch.isOn = false
            radarSwitch.accessibilityLabel = "ACC_BUTTON_ACTIVATE_RADAR".localized
            radarSwitch.isHidden = true
            setImagesInactive(false)
        }
    }

    private func showExtraMessage() {
        topActiveNotificationConstraint.priority = .defaultHigh
        topRadarTitle.priority = .defaultLow
        notificationInactiveMessageLabel.isHidden = false
        activateNotificationButton.isHidden = false
        radarSwitch.isEnabled = false
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
                message: message, buttonTitle: "ALERT_ACCEPT_BUTTON".localized,
                buttonVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized
            )
        }
    }

    private func showAlert(message: String?) {
        if let message = message {
            showAlertOk(
                title: "MESSAGE_POPUP".localized,
                message: message, buttonTitle: "ALERT_ACCEPT_BUTTON".localized,
                buttonVoiceover: "ACC_BUTTON_ALERT_ACCEPT".localized
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
            router?.route(to: Routes.exposition, from: self, parameters: info.lastCheck)
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
            buttonTitle: "ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized,
            buttonVoiceover: "ACC_HINT".localized) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    private func dissableAccesibility(isDissable: Bool) {
        self.scrollView.accessibilityElementsHidden = isDissable
        self.communicationButton.accessibilityElementsHidden = isDissable
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

extension HomeViewController: TimeExposedProtocol, TermsUpdatedProtocol {
    
    func hiddenTimeExposedView() {
        dissableAccesibility(isDissable: false)
    }
}

