//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class StatsViewController: BaseViewController {
    
    @IBOutlet weak var desCountDonwloadAppLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var countDonwloadAppLabel: UILabel!
    @IBOutlet weak var desCountPositiveLabel: UILabel!
    @IBOutlet weak var countPositiveLabel: UILabel!
    @IBOutlet weak var desCountConnectedCountryLabel: UILabel!
    @IBOutlet weak var countConnectedCountryLabel: UILabel!
    @IBOutlet weak var knowConnectedCountryLabel: UILabel!
    @IBOutlet var cards: [BackgroundView]!
    @IBOutlet weak var statsLinkLabel: UILabel!
    @IBOutlet weak var cneLinkLabel: UILabel!
    
    var router: AppRouter?
    var viewModel: StatsViewModel?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.loadFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupView()
        setupAccessibility()
    }
    
    func setupBinding() {
        viewModel?.loadFirst()
        
        viewModel?.getlastUpdateDate().subscribe(onNext: { [weak self] (value) in
            self?.changeUpdateDateLabel(date: value)
        }).disposed(by: disposeBag)
        
        viewModel?.interoperabilityCountryCount.subscribe(onNext: { [weak self] (value) in
            self?.countConnectedCountryLabel.text = "\(value)"
        }).disposed(by: disposeBag)
        
        viewModel?.getTotalAcummulatedContagious()
            .bind(to: countPositiveLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.getTotalAcummulatedDownloads()
            .bind(to: countDonwloadAppLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        cards.forEach { $0.image = UIImage(named: "WhiteCard") }
        
        desCountDonwloadAppLabel.textAlignment = .center
        desCountPositiveLabel.textAlignment = .center
        desCountConnectedCountryLabel.textAlignment = .center
        knowConnectedCountryLabel.textAlignment = .center
        
        knowConnectedCountryLabel.isUserInteractionEnabled = true
        knowConnectedCountryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                              action: #selector(userDidTapKnowConnectedCountry(tapGestureRecognizer:))))
        
        statsLinkLabel.textAlignment = .center
        statsLinkLabel.isUserInteractionEnabled = true
        statsLinkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(userDidTapStatsLink(tapGestureRecognizer:))))
        statsLinkLabel.setLineSpacing()
        
        cneLinkLabel.isUserInteractionEnabled = true
        cneLinkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                 action: #selector(userDidTapCNELink(tapGestureRecognizer:))))
        cneLinkLabel.setLineSpacing()
    }
    
    func changeUpdateDateLabel(date:Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormatWithBar
        updateDateLabel.attributedText = "STATS_UPDATE"
            .localizedAttributed(withParams: [formatter.string(from: date)])
        updateDateLabel.textAlignment = .center
        updateDateLabel.setMagnifierFontSize()
        
        updateDateLabel.accessibilityLabel = "STATS_UPDATE"
            .localizedAttributed(withParams: [date.getAccesibilityDate() ?? ""]).string
        
    }
    
    func setupAccessibility() {
        knowConnectedCountryLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)
        knowConnectedCountryLabel.accessibilityHint = "ACC_HINT".localized
        
        statsLinkLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        statsLinkLabel.accessibilityLabel = "STATS_WEB_LINK".localizedAttributed().string
        statsLinkLabel.accessibilityHint = "ACC_HINT".localized
        
        cneLinkLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        cneLinkLabel.accessibilityLabel = "STATS_WEB_LINK_CNECOVID_ISCII".localizedAttributed().string
        cneLinkLabel.accessibilityHint = "ACC_HINT".localized
    }
    
    @objc func userDidTapKnowConnectedCountry(tapGestureRecognizer: UITapGestureRecognizer) {
        router?.route(to: .detailInteroperability, from: self, parameters: nil)
    }
    
    @objc func userDidTapStatsLink(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "STATS_WEB_LINK".localized.getUrlFromHref())
    }
    
    @objc func userDidTapCNELink(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "STATS_WEB_LINK_CNECOVID_ISCII".localized.getUrlFromHref())
    }
}
