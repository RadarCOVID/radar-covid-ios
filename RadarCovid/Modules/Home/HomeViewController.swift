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
    
    private let disposeBag = DisposeBag()

    private let bgImageRed = UIImage(named: "GradientBackgroundRed")
    private let bgImageOrange = UIImage(named: "GradientBackgroundOrange")
    private let bgImageGreen = UIImage(named: "GradientBackgroundGreen")
    private let imageHomeGray = UIImage(named: "imageHome")?.grayScale
    private let imageHome = UIImage(named: "imageHome")
    private let circle = UIImage(named: "circle")
    private let circleGray = UIImage(named: "circle")?.grayScale
    
    var timeExposedDismissedUseCase: TimeExposedDismissedUseCase?
    var errorHandler: ErrorHandler!
    
    @IBOutlet weak var popupButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var moreinfo: UILabel!
    @IBOutlet weak var topRadarTitle: NSLayoutConstraint!
    @IBOutlet weak var topActiveNotification: NSLayoutConstraint!
    @IBOutlet weak var imageCircle: UIImageView!
    @IBOutlet weak var envLabel: UILabel!
    @IBOutlet weak var imageDefault: UIImageView!
    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var expositionTitle: UILabel!
    @IBOutlet weak var expositionDescription: UILabel!
    @IBOutlet weak var expositionView: BackgroundView!
    @IBOutlet weak var radarSwitch: UISwitch!
    @IBOutlet weak var radarMessage: UILabel!
    @IBOutlet weak var radarTitle: UILabel!
    @IBOutlet weak var radarView: BackgroundView!
    @IBOutlet weak var communicationButton: UIButton!
    @IBOutlet weak var activateNotificationButton: UIButton!
    @IBOutlet weak var notificationInactiveMessage: UILabel!
    @IBOutlet weak var resetDataButton: UIButton!
    @IBOutlet weak var arrowRight: UIImageView!
    
    var router: AppRouter?
    var viewModel: HomeViewModel?

    @IBAction func onCommunicate(_ sender: Any) {
        guard let expositionInfo = try? viewModel?.expositionInfo.value() else {
            return
        }
        if expositionInfo.level == .infected {
            router?.route(to: Routes.myHealthReported, from: self)
        } else {
            router?.route(to: Routes.myHealth, from: self)
        }
    }
    @IBAction func onOpenSettingsTap(_ sender: Any) {
        showActivationMessage()
    }
    
    @IBAction func onRadarSwitchChange(_ sender: Any) {
        let active = radarSwitch.isOn

        if active {
            viewModel?.changeRadarStatus(true)
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

    func showActivationMessage() {
        self.showAlertOk(
            title: "ALERT_HOME_COVID_NOTIFICATION_TITLE".localized,
            message: "HOME_COVID_NOTIFICATION_POPUP_INACTIVE".localized,
            buttonTitle: "ALERT_HOME_COVID_NOTIFICATION_OK_BUTTON".localized,
            buttonVoiceover: "ACC_HINT".localized) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    @objc func onExpositionTap() {
        if let level =  try? viewModel?.expositionInfo.value() {
            navigateToDetail(level)
        }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        radarSwitch.isAccessibilityElement = true
        viewTitle.isAccessibilityElement = true
        viewTitle.accessibilityTraits.insert(UIAccessibilityTraits.header)
        viewTitle.accessibilityLabel = "ACC_HOME_TITLE".localized
        if UIAccessibility.isVoiceOverRunning {
            viewTitle.isHidden = true
        }else{
            viewTitle.isHidden = false
        }
        setupBindings()
        arrowRight.isAccessibilityElement = true
        arrowRight.accessibilityLabel = "ACC_BUTTON_NAVIGATE_TO_EXPOSITION".localized
        arrowRight.accessibilityTraits.insert(UIAccessibilityTraits.button)
        arrowRight.accessibilityHint = "ACC_HINT".localized
        moreinfo.isUserInteractionEnabled = true
        moreinfo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapMoreInfo(tapGestureRecognizer:))))
        communicationButton.setTitle("HOME_BUTTON_SEND_POSITIVE".localized, for: .normal)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onExpositionTap))
        expositionView.addGestureRecognizer(gesture)
        radarView.image = UIImage(named: "WhiteCard")

        radarSwitch.tintColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        radarSwitch.layer.cornerRadius = radarSwitch.frame.height / 2
        radarSwitch.backgroundColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)

        resetDataButton.isHidden = !Config.debug
        envLabel.isHidden = Config.environment == "PRO"

        viewModel!.checkInitialExposition()
        viewModel!.checkOnboarding()
        viewModel!.checkExposedToHealthy()
        
        errorHandler?.alertDelegate = self

    }

    private func setupBindings() {
        viewModel?.radarStatus.subscribe { [weak self] status in
            self?.changeRadarMessage(status: status.element ?? .inactive)
        }.disposed(by: disposeBag)

        viewModel?.expositionInfo.subscribe { [weak self] exposition in
            self?.updateExpositionInfo(exposition.element)
        }.disposed(by: disposeBag)

        viewModel?.error.subscribe { [weak self] error in
            self?.errorHandler?.handle(error: error.element)
        }.disposed(by: disposeBag)

        viewModel?.alertMessage.subscribe { [weak self] message in
            self?.showAlert(message: message.element)
        }.disposed(by: disposeBag)

        viewModel?.checkState.subscribe { [weak self] showCheck in
            self?.showCheckState(showCheck.element)
        }.disposed(by: disposeBag)

        viewModel!.errorState.subscribe { [weak self] error in
            self?.setErrorState(error.element ?? nil)
        }.disposed(by: disposeBag)
        
        viewModel?.expositionCheck.subscribe { [weak self] expositionCheck in
            if (expositionCheck.element ?? false){
                if self?.timeExposedDismissedUseCase?.isTimeExposedDismissed() == false {
                    self?.showTimeExposed();
                }
            }
        }.disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.restoreLastStateAndSync()
    }

    @IBAction func onReset(_ sender: Any) {

        self.showAlertCancelContinue(
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
    
    func showTimeExposed() {
        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1)
        TimeExposedView.initWithParentViewController(viewController: self)
       
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
        viewModel?.setTimeExposedDismissed(value: false) 
        expositionTitle.text = "HOME_EXPOSITION_TITLE_HIGH".localized
        expositionDescription.attributedText = "HOME_EXPOSITION_MESSAGE_HIGH".localizedAttributed(
            withParams: ["CONTACT_PHONE".localized]
        )
        expositionView.image = bgImageOrange
        expositionTitle.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        communicationButton.isHidden = false
        moreinfo.isHidden = true
    }

    private func setHealthy() {
        expositionTitle.text = "HOME_EXPOSITION_TITLE_LOW".localized
        expositionDescription.locKey  = "HOME_EXPOSITION_MESSAGE_LOW"
        expositionView.image = bgImageGreen
        expositionTitle.textColor = #colorLiteral(red: 0.3449999988, green: 0.6899999976, blue: 0.4160000086, alpha: 1)
        communicationButton.isHidden = false
        moreinfo.isHidden = true
    }

    private func setInfected() {
        expositionTitle.text = "HOME_EXPOSITION_TITLE_POSITIVE".localized
        expositionDescription.locKey = "HOME_EXPOSITION_MESSAGE_INFECTED"
        expositionView.image = bgImageRed
        expositionTitle.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
        communicationButton.isHidden = true
        moreinfo.isHidden = false
    }

    private func setImagesInactive(_ inactive: Bool) {
        if inactive {
            imageDefault.image = imageHomeGray
            imageCircle.image = circleGray
        } else {
            imageDefault.image = imageHome
            imageCircle.image = circle
        }
    }
    private func setErrorState(_ error: DomainError?) {

        if let error = error {
            switch error {
            case .bluetoothTurnedOff:
                changeRadarMessage(status: .inactive)
                notificationInactiveMessage.text = "HOME_BLUETOOTH_INACTIVE_MESSAGE".localized
                showExtraMessage()
                activateNotificationButton.isHidden = true
            case .notAuthorized:
                changeRadarMessage(status: .inactive)
                notificationInactiveMessage.text = "HOME_NOTIFICATION_INACTIVE_MESSAGE".localized
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
            radarTitle.text = "HOME_RADAR_TITLE_ACTIVE".localized
            radarMessage.text = "HOME_RADAR_CONTENT_ACTIVE".localized
            radarMessage.textColor = UIColor.black
            radarSwitch.isOn = true
            radarSwitch.accessibilityLabel = "ACC_BUTTON_DEACTIVATE_RADAR".localized
            setImagesInactive(false)
        case .inactive:
            radarTitle.text = "HOME_RADAR_TITLE_INACTIVE".localized
            radarMessage.text = "HOME_RADAR_CONTENT_INACTIVE".localized
            radarMessage.textColor = #colorLiteral(red: 0.878000021, green: 0.423999995, blue: 0.3409999907, alpha: 1)
            radarSwitch.isOn = false
            radarSwitch.accessibilityLabel = "ACC_BUTTON_ACTIVATE_RADAR".localized
            setImagesInactive(true)
        case .disabled:
            radarTitle.text = "HOME_RADAR_TITLE_INACTIVE".localized
            radarMessage.text = "HOME_RADAR_MESSAGE_DISABLED".localized
            radarMessage.textColor = UIColor.black
            radarSwitch.isOn = false
            radarSwitch.accessibilityLabel = "ACC_BUTTON_ACTIVATE_RADAR".localized
            radarSwitch.isHidden = true
            setImagesInactive(false)
        }
    }
    
    private func showExtraMessage() {
        topActiveNotification.priority = .defaultHigh
        topRadarTitle.priority = .defaultLow
        notificationInactiveMessage.isHidden = false
        activateNotificationButton.isHidden = false
        radarSwitch.isEnabled = false
    }
    private func hideExtraMessage() {
        topActiveNotification.priority = .defaultLow
        topRadarTitle.priority = .defaultHigh
        notificationInactiveMessage.isHidden = true
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
        imageCheck.isHidden = !showCheck
        imageDefault.isHidden = showCheck
    }
    
    @objc func userDidTapMoreInfo(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "EXPOSITION_HIGH_MORE_INFO_URL".localized)
    }
    

}


extension HomeViewController: AccTitleView {

    var accTitle: String? {
        get {
            "ACC_HOME_TITLE".localized
        }
    }
}
