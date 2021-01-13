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

protocol Router {
    func route(
        to routeID: Routes,
        from context: UIViewController,
        parameters: Any?...
    )
    func popToRoot(from: UIViewController, animated: Bool)
    func pop(from: UIViewController, animated: Bool)
}

public enum Routes {
    case root
    case welcome
    case onBoarding
    case home
    case proximity
    case myHealthStep0
    case myHealthStep1
    case myHealthStep2
    case myHealthReported
    case healthyExposition
    case highExposition
    case positiveExposed
    case activateCovid
    case activatePush
    case changeLanguage
    case shareApp
    case timeExposed
    case termsUpdated
    case detailInteroperability
    case infoApp
    case helpSettings
    case unsupportedOS
}


class AppRouter: Router {

    var parentVC: UIViewController?

    func routes(to routeIDs: [Routes], from context: UIViewController, parameters: [Any?]?) {
        parentVC = context
        
        var index:Int = 1
        var newParentViewController: UIViewController?

        
        for itemRouteId in routeIDs {
            
            let sendParameters = index >= routeIDs.count ? parameters : nil

            if index == 1 {
                let nvC = context.navigationController
                route(to: itemRouteId, from: context, parameters: sendParameters)
                newParentViewController = nvC?.viewControllers.first
            } else {
                route(to: itemRouteId, from: newParentViewController ?? context, parameters: sendParameters)
            }
            index = 1 + index
        }
    }
    
    func route(to routeID: Routes, from context: UIViewController, parameters: Any?...) {
        route(to: routeID, from: context, parameters: parameters.map { $0 } )
    }
    
    func route(to routeID: Routes, from context: UIViewController, parameters: [Any?]?) {
        parentVC = context
        switch routeID {
        case .root:
            if let param = parameters,
               param.count >= 2 {
                routeToRoot(context, urlSchemeRedirect: param[0] as? [Routes], paramsUrlScheme: param[1] as? [Any?])
            } else {
                routeToRoot(context, urlSchemeRedirect: nil, paramsUrlScheme: [])
            }
        case .welcome:
            routeToWelcome(context)
        case .onBoarding:
            routeToOnboarding(context)
        case .home:
            routeToHome(context)
        case .proximity:
            routeToProximity(context)
        case .activateCovid:
            routeToCovid(context)
        case .activatePush:
            routeToPush(context)
        case .myHealthStep0:
            routeToMyHealthStep0(context)
        case .myHealthStep1:
            if let param = parameters,
               param.count >= 1 {
                routeToMyHealthStep1(context, covidCode: param[0] as? String ?? "")
            } else {
                routeToMyHealthStep1(context)
            }
        case .myHealthStep2:
            if let param = parameters,
               param.count >= 2 {
                routeToMyHealthStep2(context, codeString: param[0] as? String ?? "", dateNotificationPositive: param[1] as? Date)
            }
            
        case .myHealthReported:
            routeToMyHealthReported(context)
        case .healthyExposition:
            if let param = parameters,
               param.count >= 1 {
                routeToHealthyExposition(context, lastCheck: param[0] as? Date)
            }
            
        case .highExposition:
            if let param = parameters,
               param.count >= 1 {
                routeToHighExposition(context, since: param[0] as? Date)
            }
            
        case .positiveExposed:
            if let param = parameters,
               param.count >= 1 {
                routeToPositiveExposed(context, since: param[0] as? Date)
            }
            
        case .changeLanguage:
            routeToRootAndResetView(context)
        case .shareApp:
            routeToShareApp(context)
        case .timeExposed:
            routeToTimeExposed(context)
        case .termsUpdated:
            routeToTermsUpdated(context)
        case .detailInteroperability:
            routeToDetailInteroperability(context)
        case .infoApp:
            routeToInfoApp(context)
        case .helpSettings:
            routeToHelpSettings(context)
        case .unsupportedOS:
            routeToUnsupportedOS(context)
        }
    }

    private func routeToOnboarding(_ context: UIViewController) {
        let onBoardingVC = AppDelegate.shared?.injection.resolve(OnBoardingViewController.self)!
        context.navigationController?.pushViewController(onBoardingVC!, animated: true)
    }

    private func routeToRoot(_ context: UIViewController, urlSchemeRedirect: [Routes]?, paramsUrlScheme: [Any?]?) {
        let rootVC = AppDelegate.shared?.injection.resolve(RootViewController.self)!
        rootVC?.urlSchemeRedirect = urlSchemeRedirect
        rootVC?.paramsUrlScheme = paramsUrlScheme
        loadViewAsRoot(navController: context as? UINavigationController, view: rootVC!)
    }
    
    private func routeToRootAndResetView(_ context: UIViewController) {
        let rootVC = AppDelegate.shared?.injection.resolve(RootViewController.self)!
        loadViewAsRoot(navController: context.navigationController, view: rootVC!)
    }
    
    private func routeToShareApp(_ context: UIViewController) {
        let shareAppVC = AppDelegate.shared?.injection.resolve(ShareAppViewController.self)!
        loadViewAsModal(viewParentController: context, view: shareAppVC!)
    }
    
    private func routeToTimeExposed(_ context: UIViewController) {
        let timeExposedVC = AppDelegate.shared?.injection.resolve(TimeExposedViewController.self)!
        loadViewAsModal(viewParentController: context, view: timeExposedVC!)
    }
    
    private func routeToTermsUpdated(_ context: UIViewController) {
        let termsUpdatedVC = AppDelegate.shared?.injection.resolve(TermsUpdatedViewController.self)!
        loadViewAsModal(viewParentController: context, view: termsUpdatedVC!)
    }
    
    private func routeToDetailInteroperability(_ context: UIViewController) {
        let termsUpdatedVC = AppDelegate.shared?.injection.resolve(DetailInteroperabilityViewController.self)!
        loadViewAsModal(viewParentController: context, view: termsUpdatedVC!)
    }
    
    private func routeToInfoApp(_ context: UIViewController) {
        let infoAppVC = AppDelegate.shared?.injection.resolve(InformationViewController.self)!
        context.navigationController?.pushViewController(infoAppVC!, animated: true)
    }
    
    private func routeToHelpSettings(_ context: UIViewController) {
        let helpSettingsVC = AppDelegate.shared?.injection.resolve(HelpSettingsViewController.self)!
        loadViewAsModal(viewParentController: context, view: helpSettingsVC!)
    }
    
    private func routeToUnsupportedOS(_ context: UIViewController) {
        let unsupportedOSVC = AppDelegate.shared?.injection.resolve(UnsupportedOSViewController.self)!
        loadViewAsRoot(navController: context as? UINavigationController, view: unsupportedOSVC!)
    }
    
    private func routeToHome(_ context: UIViewController) {
        let tabBarController = AppDelegate.shared?.injection.resolve(TabBarController.self)!
        loadViewAsRoot(navController: context.navigationController, view: tabBarController!)
    }

    private func routeToProximity(_ context: UIViewController) {
        let proxymityVC = AppDelegate.shared?.injection.resolve(ProximityViewController.self)!
        context.navigationController?.pushViewController(proxymityVC!, animated: true)
    }

    private func routeToCovid(_ context: UIViewController) {
        let activateCovid = AppDelegate.shared?.injection.resolve(ActivateCovidNotificationViewController.self)!
       context.navigationController?.pushViewController(activateCovid!, animated: true)
    }

    private func routeToPush(_ context: UIViewController) {
        let activatePush = AppDelegate.shared?.injection.resolve(ActivatePushNotificationViewController.self)!
       context.navigationController?.pushViewController(activatePush!, animated: true)
    }

    private func routeToMyHealthStep0(_ context: UIViewController) {
        let myHealthStep0VC = AppDelegate.shared?.injection.resolve(MyHealthStep0ViewController.self)!
        context.navigationController?.pushViewController(myHealthStep0VC!, animated: true)
    }
    
    private func routeToMyHealthStep1(_ context: UIViewController, covidCode: String = "") {
        let myHealthStep1VC = AppDelegate.shared?.injection.resolve(MyHealthStep1ViewController.self)!
        myHealthStep1VC?.covidCode = covidCode
        context.navigationController?.pushViewController(myHealthStep1VC!, animated: true)
    }
    
    private func routeToMyHealthStep2(_ context: UIViewController, codeString: String, dateNotificationPositive: Date?) {
        let myHealthStep2VC = AppDelegate.shared?.injection.resolve(MyHealthStep2ViewController.self)!
        myHealthStep2VC?.codeString = codeString
        myHealthStep2VC?.dateNotificationPositive = dateNotificationPositive
        context.navigationController?.pushViewController(myHealthStep2VC!, animated: true)
    }

    private func routeToMyHealthReported(_ context: UIViewController) {
        let myHealthReportedVC = AppDelegate.shared?.injection.resolve(MyHealthReportedViewController.self)!
        context.navigationController?.pushViewController(myHealthReportedVC!, animated: true)
    }

    private func routeToHealthyExposition(_ context: UIViewController, lastCheck: Date?) {
        let expositionVC = AppDelegate.shared?.injection.resolve(HealthyExpositionViewController.self)!
        expositionVC?.lastCheck = lastCheck
        context.navigationController?.pushViewController(expositionVC!, animated: true)
    }

    private func routeToHighExposition(_ context: UIViewController, since: Date?) {
        let highExpositionVC = AppDelegate.shared?.injection.resolve(HighExpositionViewController.self)!
        highExpositionVC?.since = since
        context.navigationController?.pushViewController(highExpositionVC!, animated: true)
    }

    private func routeToPositiveExposed(_ context: UIViewController, since: Date?) {
        let positiveExposedVC = AppDelegate.shared?.injection.resolve(PositiveExposedViewController.self)!
        positiveExposedVC?.since = since
        context.navigationController?.pushViewController(positiveExposedVC!, animated: true)
    }

    private func routeToWelcome(_ context: UIViewController) {
        let welcomeVC = AppDelegate.shared!.injection.resolve(WelcomeViewController.self)!
        loadViewAsRoot(navController: context.navigationController, view: welcomeVC)
    }
    
    private func loadViewAsRoot(navController: UINavigationController?, view: UIViewController, animated: Bool = false) {
        navController?.viewControllers.removeAll()
        navController?.popToRootViewController(animated: false)
        navController?.pushViewController(view, animated: animated)
    }
    
    private func loadViewAsModal(viewParentController: UIViewController, view: UIViewController) {
        view.modalPresentationStyle = .overFullScreen
        view.modalTransitionStyle = .crossDissolve
        viewParentController.present(view, animated: true, completion: nil)
    }
    
    func dissmiss(view: UIViewController, animated: Bool) {
        view.dismiss(animated: animated, completion: nil)
    }

    func popToRoot(from: UIViewController, animated: Bool) {
        from.navigationController?.popToRootViewController(animated: animated)
        parentVC = nil
    }

    func pop(from: UIViewController, animated: Bool) {
        from.navigationController?.popViewController(animated: animated)
        parentVC?.viewWillAppear(animated)
        parentVC = nil
    }

}
