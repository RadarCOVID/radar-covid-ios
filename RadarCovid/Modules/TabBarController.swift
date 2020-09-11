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
    var localizationUseCase: LocalizationUseCase
    var homeViewController: HomeViewController
    var myDataViewController: MyDataViewController
    var helpLineViewController: HelpLineViewController
    var preferencesRepository: PreferencesRepository?
    private let disposeBag = DisposeBag()

    init(localizationUseCase: LocalizationUseCase, homeViewController: HomeViewController, myDataViewController: MyDataViewController, helpLineViewController: HelpLineViewController, preferencesRepository: PreferencesRepository) {
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
    // The tabBar top border is done using the `shadowImage` and `backgroundImage` properties.
    // We need to override those properties to set the custom top border.
    // Setting the `backgroundImage` to an empty image to remove the default border. tabBar.backgroundImage = UIImage()
    // The `shadowImage` property is the one that we will use to set the custom top border.
    // We will create the `UIImage` of 1x5 points size filled with the red color and assign it to the `shadowImage` property.
    // This image then will get repeated and create the red top border of 5 points width.
    // A helper function that creates an image of the given size filled with the given color.
    // http://stackoverflow.com/a/39604716/1300959
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image

    }
    // Setting the `shadowImage` property to the `UIImage` 1x5 red.

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        // accesibility
        self.localizationUseCase.localizationLoaded.subscribe(
            onNext: { [weak self] (loaded) in
                // all is ok so we can continue
                self?.homeViewController.tabBarItem.isAccessibilityElement = true
                self?.homeViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
                let home_acc_label = "ACC_HOME_TITLE".localized
                print (home_acc_label)
                self?.homeViewController.tabBarItem.accessibilityLabel = "ACC_HOME_TITLE".localized
                self?.homeViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
                
                
                
                self?.myDataViewController.tabBarItem.isAccessibilityElement = true
                self?.myDataViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
                
                let myData_acc_label = "ACC_MYDATA_TITLE".localized
                print (myData_acc_label)
                self?.myDataViewController.tabBarItem.accessibilityLabel = "ACC_MYDATA_TITLE".localized
                self?.myDataViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
                
                
                self?.helpLineViewController.tabBarItem.isAccessibilityElement = true
                self?.helpLineViewController.tabBarItem.accessibilityTraits.insert(UIAccessibilityTraits.button)
                self?.helpLineViewController.tabBarItem.accessibilityLabel = "ACC_HELPLINE_TITLE".localized
                self?.helpLineViewController.tabBarItem.accessibilityHint = "ACC_HINT".localized
                
            }).disposed(by: self.disposeBag)
        

    }

    override func viewWillAppear(_ animated: Bool) {
        setViewControllers([homeViewController, myDataViewController, helpLineViewController], animated: false)
    }

}

extension TabBarController: AccTitleView {
    var accTitle: String? {
        (selectedViewController as? AccTitleView)?.accTitle ?? selectedViewController?.title
    }
}
