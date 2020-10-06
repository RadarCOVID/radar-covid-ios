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
    case myHealth
    case myHealthReported
    case exposition
    case highExposition
    case positiveExposed
    case activateCovid
    case activatePush
    case changeLanguage
}

class AppRouter: Router {

    var parentVC: UIViewController?

    func route(to routeID: Routes, from context: UIViewController, parameters: Any?...) {
        parentVC = context
        switch routeID {
        case .root:
            routeToRoot(context)
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
        case .myHealth:
            routeToMyHealth(context)
        case .myHealthReported:
            routeToMyHealthReported(context)
        case .exposition:
            routeToExposition(context, lastCheck: parameters[0] as? Date)
        case .highExposition:
            routeToHighExposition(context, since: parameters[0] as? Date)
        case .positiveExposed:
            routeToPositiveExposed(context, since: parameters[0] as? Date)
        case .changeLanguage:
            routeToRootAndResetView(context)
        }
    }

    private func routeToOnboarding(_ context: UIViewController) {
        let onBoardingVC = AppDelegate.shared?.injection.resolve(OnBoardingViewController.self)!
        context.navigationController?.pushViewController(onBoardingVC!, animated: true)
    }

    private func routeToRoot(_ context: UIViewController) {
        let rootVC = AppDelegate.shared?.injection.resolve(RootViewController.self)!
        loadViewAsRoot(navController: context as? UINavigationController, view: rootVC!)
    }
    
    private func routeToRootAndResetView(_ context: UIViewController) {
        let rootVC = AppDelegate.shared?.injection.resolve(RootViewController.self)!
        loadViewAsRoot(navController: context.navigationController, view: rootVC!)
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

    private func routeToMyHealth(_ context: UIViewController) {
        let myHealthVC = AppDelegate.shared?.injection.resolve(MyHealthViewController.self)!
        context.navigationController?.pushViewController(myHealthVC!, animated: true)
    }

    private func routeToMyHealthReported(_ context: UIViewController) {
        let myHealthReportedVC = AppDelegate.shared?.injection.resolve(MyHealthReportedViewController.self)!
        context.navigationController?.pushViewController(myHealthReportedVC!, animated: true)
    }

    private func routeToExposition(_ context: UIViewController, lastCheck: Date?) {
        let expositionVC = AppDelegate.shared?.injection.resolve(ExpositionViewController.self)!
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
