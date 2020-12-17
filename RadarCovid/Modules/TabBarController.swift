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
    
    var homeViewController: HomeViewController
    var myDataViewController: MyDataViewController
    var helpLineViewController: HelpLineViewController
    var settingViewController: SettingViewController
    var statsViewController: StatsViewController
    var localizationUseCase: LocalizationUseCase
    var preferencesRepository: PreferencesRepository?

    init(homeViewController: HomeViewController,
         myDataViewController: MyDataViewController,
         helpLineViewController: HelpLineViewController,
         statsViewController: StatsViewController,
         settingViewController: SettingViewController,
         preferencesRepository: PreferencesRepository,
         localizationUseCase: LocalizationUseCase) {
        
        self.homeViewController = homeViewController
        self.myDataViewController = myDataViewController
        self.helpLineViewController = helpLineViewController
        self.settingViewController = settingViewController
        self.statsViewController = statsViewController
        
        self.localizationUseCase = localizationUseCase
        self.preferencesRepository = preferencesRepository

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
        setViewControllers([homeViewController, myDataViewController, helpLineViewController, statsViewController, settingViewController], animated: false)
    }
    
    private func setupAccessibility() {
        homeViewController.tabBarItem.isAccessibilityElement = true
        homeViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        homeViewController.tabBarItem.accessibilityLabel = "ACC_HOME_TITLE".localized
        homeViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized

        myDataViewController.tabBarItem.isAccessibilityElement = true
        myDataViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
        myDataViewController.tabBarItem.accessibilityLabel = "ACC_MYDATA_TITLE".localized
        myDataViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized

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
    }
    
    private func setupView() {
        
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true
        tabBar.barStyle = .default
        tabBar.layer.cornerRadius = 15

        let apareance = UITabBarAppearance()
        apareance.backgroundImage = UIImage.init(named: "tabBarBG")
        tabBar.clipsToBounds = true
        tabBar.standardAppearance = apareance
        tabBar.unselectedItemTintColor = UIColor.black;
        tabBar.tintColor = UIColor.twilight
       
        homeViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuHomeNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "MenuHomeSelected"))
        myDataViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuInfoNormal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal),
            selectedImage: UIImage(named: "MenuInfoSelected"))
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
}

extension TabBarController: AccTitleView {
    var accTitle: String? {
        (selectedViewController as? AccTitleView)?.accTitle ?? selectedViewController?.title
    }
}
