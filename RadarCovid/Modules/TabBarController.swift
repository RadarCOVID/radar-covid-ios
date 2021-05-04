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
import RxSwift
import UIKit

class TabBarController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    
    private let homeViewController: HomeViewController!
    private let helpLineViewController: HelpLineViewController!
    private let settingViewController: SettingViewController!
    private let statsViewController: StatsViewController!
    private let venueRecordViewController: VenueRecordStartViewController!
    
    private let localizationUseCase: LocalizationUseCase!
    private let venueRecodrUseCase: VenueRecordUseCase!
    
    private let preferencesRepository: PreferencesRepository!
    
    var selectTabType: UIViewController.Type?

    init(homeViewController: HomeViewController,
         helpLineViewController: HelpLineViewController,
         statsViewController: StatsViewController,
         settingViewController: SettingViewController,
         preferencesRepository: PreferencesRepository,
         localizationUseCase: LocalizationUseCase,
         venueRecordViewController: VenueRecordStartViewController,
         venueRecodrUseCase: VenueRecordUseCase) {
        
        self.homeViewController = homeViewController
        self.helpLineViewController = helpLineViewController
        self.settingViewController = settingViewController
        self.statsViewController = statsViewController
        
        self.localizationUseCase = localizationUseCase
        self.preferencesRepository = preferencesRepository
        self.venueRecordViewController = venueRecordViewController
        self.venueRecodrUseCase = venueRecodrUseCase

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func isDissableAccesibility(isDisabble: Bool) {
        self.tabBar.isHidden = isDisabble
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAccessibility()
        setViewControllers([homeViewController,venueRecordViewController, statsViewController, helpLineViewController, settingViewController ], animated: false)
        
        select(tabType: selectTabType)
        
        loadBadges()
    }
    
    private func setupAccessibility() {
        homeViewController.tabBarItem.isAccessibilityElement = true
        homeViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        homeViewController.tabBarItem.accessibilityLabel = "ACC_HOME_TITLE".localized
        homeViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized

        helpLineViewController.tabBarItem.isAccessibilityElement = true
        helpLineViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        helpLineViewController.tabBarItem.accessibilityLabel = "ACC_HELPLINE_TITLE".localized
        helpLineViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
        
        statsViewController.tabBarItem.isAccessibilityElement = true
        statsViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        statsViewController.tabBarItem.accessibilityLabel = "ACC_STATS_TITLE".localized
        statsViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
        
        settingViewController.tabBarItem.isAccessibilityElement = true
        settingViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        settingViewController.tabBarItem.accessibilityLabel = "ACC_SETTINGS_TITLE".localized
        settingViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
        
        
        venueRecordViewController.tabBarItem.isAccessibilityElement = true
        venueRecordViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        venueRecordViewController.tabBarItem.accessibilityLabel = "ACC_VENUE_TITLE".localized
        venueRecordViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
        
        
    }
    
    private func setupView() {
        
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true
        tabBar.barStyle = .default
        tabBar.layer.cornerRadius = 15

        tabBar.clipsToBounds = true
        tabBar.unselectedItemTintColor = UIColor.black;
        tabBar.tintColor = UIColor.twilight
       
        homeViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuHomeNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "MenuHomeSelected"))
        
        venueRecordViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "QrNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "QrNormal"))
        
        helpLineViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuHelpNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "MenuHelpSelected"))
        
        statsViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuStatsNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "MenuStatsSelected"))
        
        settingViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuSettingNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "MenuSettingSelected"))
        
        
    }
    
    private func select(tabType: UIViewController.Type?) {
        if let t = tabType, let vcs = viewControllers {
            for (index, vc) in vcs.enumerated() {
                if type(of: vc) === t {
                    self.selectedIndex = index
                }
            }
        }
    }
    
    private func loadBadges() {
        venueRecodrUseCase.isCheckedIn().subscribe ( onNext: { [weak self] checked in
            if checked {
                self?.venueRecordViewController.tabBarItem.badgeValue = ""
                self?.venueRecordViewController.tabBarItem.accessibilityLabel = "ACC_VENUE_TITLE".localized + ". " + "VENUE_RECORD_CHECKIN_TITLE".localized
            } else {
                self?.venueRecordViewController.tabBarItem.badgeValue = nil
                self?.venueRecordViewController.tabBarItem.accessibilityLabel = "ACC_VENUE_TITLE".localized
            }
        }).disposed(by: disposeBag)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectTabType = nil
    }
    
}

extension TabBarController: AccTitleView {
    var accTitle: String? {
        (selectedViewController as? AccTitleView)?.accTitle ?? selectedViewController?.title
    }
}
