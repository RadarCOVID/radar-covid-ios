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
    
    // MARK: - Properties
    var localizationUseCase: LocalizationUseCase
    var homeViewController: HomeViewController
    var myDataViewController: MyDataViewController
    var helpLineViewController: HelpLineViewController
    var preferencesRepository: PreferencesRepository?

    
    // MARK: - Constructor
    init(localizationUseCase: LocalizationUseCase,
         homeViewController: HomeViewController,
         myDataViewController: MyDataViewController,
         helpLineViewController: HelpLineViewController,
         preferencesRepository: PreferencesRepository) {
        
        self.localizationUseCase = localizationUseCase
        self.homeViewController = homeViewController
        self.myDataViewController = myDataViewController
        self.helpLineViewController = helpLineViewController
        self.preferencesRepository = preferencesRepository

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle Methods.

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupAccessibility()
        setViewControllers([homeViewController, myDataViewController, helpLineViewController], animated: false)
    }
}

//MARK: - Accesibility.
extension TabBarController {
    
    func setupAccessibility() {
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
    }
}

//MARK: - AccTitleView.
extension TabBarController: AccTitleView {
    var accTitle: String? {
        (selectedViewController as? AccTitleView)?.accTitle ?? selectedViewController?.title
    }
}

//MARK: - Private.
extension TabBarController {
     
    func setupView() {
        
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true
        tabBar.barStyle = .default
        tabBar.layer.cornerRadius = 15

        let apareance = UITabBarAppearance()
        apareance.backgroundImage = UIImage.init(named: "tabBarBG")
        tabBar.clipsToBounds = true
        tabBar.standardAppearance = apareance

        homeViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuHomeNormal"),
            selectedImage: UIImage(named: "MenuHomeSelected"))
        myDataViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuInfoNormal"),
            selectedImage: UIImage(named: "MenuInfoSelected"))
        helpLineViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "MenuHelpNormal"),
            selectedImage: UIImage(named: "MenuHelpSelected"))
    }
}
