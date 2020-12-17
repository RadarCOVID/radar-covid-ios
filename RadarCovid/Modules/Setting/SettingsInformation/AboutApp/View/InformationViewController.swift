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
import MessageUI

class InformationViewController: BaseViewController {
    
    @IBOutlet weak var notificationStateValue: UILabel!
    @IBOutlet weak var lastSyncValue: UILabel!
    @IBOutlet weak var lastSyncAgo: UILabel!
    @IBOutlet weak var bluetoothValue: UILabel!
    @IBOutlet weak var learnKeepRadarActive: UILabel!
    @IBOutlet weak var versionValue: UILabel!
    @IBOutlet weak var lastUpdateValue: UILabel!
    @IBOutlet weak var soValue: UILabel!
    @IBOutlet weak var modelValue: UILabel!
    @IBOutlet weak var faqLink: UILabel!
    @IBOutlet weak var emailLink: UILabel!
    @IBOutlet weak var radarStateValue: UILabel!
    @IBOutlet weak var radarIcon: UIImageView!
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var lastSyncIcon: UIImageView!
    @IBOutlet weak var bluetoothIcon: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bottomBackButton: UIButton!
    
    var router: AppRouter?
    var viewModel: InformationViewModel?
    
    private let imageActive = UIImage(named: "green_check_icon")
    private let imageInactive = UIImage(named: "forbidenIcon")
    private let imageNoSync = UIImage(named: "ic_noSync")
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
        setupView()
        setupAccessibility()
    }
    
    private func setupBind() {
        viewModel?.appInformation
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (value) in
                self?.updateInformation(appInformation: value)
            }).disposed(by: disposeBag)
    }
    
    private func setupView() {
        viewModel?.getAppInformation()
        
        learnKeepRadarActive.isUserInteractionEnabled = true
        learnKeepRadarActive.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(userDidTapLearn(tapGestureRecognizer:))))
        faqLink.isUserInteractionEnabled = true
        faqLink.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(userDidTapFAQ(tapGestureRecognizer:))))
        emailLink.isUserInteractionEnabled = true
        emailLink.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(userDidTapShare(tapGestureRecognizer:))))
        infoView.setShadow()
    }
    
    private func setupAccessibility() {
        
        learnKeepRadarActive.accessibilityTraits.insert(UIAccessibilityTraits.button)
        learnKeepRadarActive.accessibilityHint = "ACC_HINT".localized
        
        faqLink.accessibilityTraits.insert(UIAccessibilityTraits.link)
        faqLink.accessibilityHint = "ACC_HINT".localized
        
        emailLink.accessibilityTextualContext = .sourceCode
        let emailLinkString = emailLink.attributedText?.mutableCopy() as? NSMutableAttributedString
        emailLinkString?.beginEditing()
        emailLinkString?.addAttribute(.accessibilitySpeechPunctuation, value: true, range: NSRange(location: 0, length: emailLinkString?.length ?? 0))
        emailLinkString?.endEditing()
        emailLink.attributedText = emailLinkString
        emailLink.accessibilityHint = "ACC_HINT".localized
        
        bottomBackButton.isAccessibilityElement = true
        let previous = navigationController?.previousViewController
        if let strTitle = (previous as? AccTitleView)?.accTitle ?? previous?.title {
            bottomBackButton.accessibilityLabel =  "\(strTitle) " + "ACC_BUTTON_BACK_TO".localized
        } else {
            bottomBackButton.accessibilityLabel = "ACC_BUTTON_BACK".localized
        }
        bottomBackButton.accessibilityHint = "ACC_HINT".localized
    }
    
    private func updateInformation(appInformation: AppInformation) {
        let appVersionString = appInformation.version
        self.versionValue.text = appVersionString
        self.versionValue.setMagnifierFontSize()
        self.radarStateValue.text = appInformation.radarStatus ? "ACTIVE".localized : "INACTIVE".localized
        self.radarStateValue.setMagnifierFontSize()

        self.radarStateValue.textColor = appInformation.radarStatus ? UIColor.systemGreen : UIColor.red

        self.radarIcon.image = appInformation.radarStatus ? imageActive : imageInactive
        self.notificationStateValue.text =
            appInformation.notificationStatus ? "ACTIVE".localized : "INACTIVE".localized
        self.notificationStateValue.setMagnifierFontSize()
        self.notificationIcon.image = appInformation.notificationStatus ? imageActive : imageInactive
        self.notificationStateValue.textColor = appInformation.notificationStatus ? UIColor.systemGreen : UIColor.red
        self.bluetoothValue.text = appInformation.bluetooth ? "ACTIVE".localized : "INACTIVE".localized
        self.bluetoothValue.setMagnifierFontSize()
        self.bluetoothIcon.image = appInformation.bluetooth ? imageActive : imageInactive
        self.bluetoothValue.textColor = appInformation.bluetooth ? UIColor.systemGreen : UIColor.red
        
        if let lastSync = appInformation.lastSync {
            self.lastSyncValue.text = viewModel?.formatDate(date: lastSync)
            let syncDate:Int? = appInformation.getSyncDateDiff()
            if syncDate == 0 {
                self.lastSyncAgo.text = "INFO_LAST_SYNC_UPDATE".localized
            } else if syncDate == 1 {
                self.lastSyncAgo.text = "INFO_LAST_SYNC_ONE_DAY".localized
            } else if let syncDate = syncDate {
                self.lastSyncAgo.text = "INFO_LAST_SYNC_ANYMORE"
                    .localizedAttributed(withParams: [String(syncDate)]).string
            } else {
                self.lastSyncAgo.text = "INFO_LAST_SYNC_UPDATE".localized
            }
        
            
            self.lastSyncAgo.textColor = appInformation.checkSyncDate() ? UIColor.systemGreen : UIColor.red
            self.lastSyncIcon.image = appInformation.checkSyncDate() ? imageActive : imageInactive

        } else {
            self.lastSyncAgo.text = "INFO_LAST_NO_SYNC_UPDATE".localized
            self.lastSyncValue.text = "---"
            self.lastSyncIcon.image = imageNoSync
        }
        self.lastSyncValue.setMagnifierFontSize()
        self.lastSyncAgo.setMagnifierFontSize()


        let lastUpdateValueString = viewModel?.formatDate(date: appInformation.lastUpdate) ?? ""
        self.lastUpdateValue.text = lastUpdateValueString
        self.lastUpdateValue.setMagnifierFontSize()
        self.soValue.text = appInformation.so
        self.soValue.setMagnifierFontSize()
        self.modelValue.text = appInformation.model
        self.modelValue.setMagnifierFontSize()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.router?.pop(from: self, animated: true)
    }
    
    @objc func userDidTapLearn(tapGestureRecognizer: UITapGestureRecognizer) {
        router?.route(to: .helpSettings, from: self)
    }
    
    @objc func userDidTapFAQ(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "INFO_FAQ_LINK".localized.getUrlFromHref())
    }
    
    @objc func userDidTapShare(tapGestureRecognizer: UITapGestureRecognizer) {
        let messageBody = self.viewModel?.strBuildShareMessage ?? ""
        let toRecipents = ["INFO_TECHNICAL_HELP_EMAIL".localized]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setMessageBody(messageBody, isHTML: true)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
}

extension InformationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

