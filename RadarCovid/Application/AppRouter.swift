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

}

class AppRouter: Router {

    var proxymityVC: ProximityViewController?
    var onBoardingVC: OnBoardingViewController?
    var rootVC: RootViewController?
    var tabBarController: TabBarController?
    var myHealthVC: MyHealthViewController?
    var myHealthReportedVC: MyHealthReportedViewController?
    var expositionVC: ExpositionViewController?
    var highExpositionVC: HighExpositionViewController?
    var positiveExposedVC: PositiveExposedViewController?
    var welcomeVC: WelcomeViewController?
    var activateCovid: ActivateCovidNotificationViewController?
    var activatePush: ActivatePushNotificationViewController?

    func route(to routeID: Routes, from context: UIViewController, parameters: Any?...) {
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
        }
    }

    private func routeToOnboarding(_ context: UIViewController) {
        context.navigationController?.pushViewController(onBoardingVC!, animated: true)
    }

    private func routeToRoot(_ context: UIViewController) {
        loadViewAsRoot(navController: context as? UINavigationController, view: rootVC!)
    }

    private func routeToHome(_ context: UIViewController) {
        loadViewAsRoot(navController: context.navigationController, view: tabBarController!)
    }

    private func routeToProximity(_ context: UIViewController) {
        context.navigationController?.pushViewController(proxymityVC!, animated: true)
    }

    private func routeToCovid(_ context: UIViewController) {
       context.navigationController?.pushViewController(activateCovid!, animated: true)
    }

    private func routeToPush(_ context: UIViewController) {
       context.navigationController?.pushViewController(activatePush!, animated: true)
    }

    private func routeToMyHealth(_ context: UIViewController) {
        context.navigationController?.pushViewController(myHealthVC!, animated: true)
    }

    private func routeToMyHealthReported(_ context: UIViewController) {
        context.navigationController?.pushViewController(myHealthReportedVC!, animated: true)
    }

    private func routeToExposition(_ context: UIViewController, lastCheck: Date?) {
        expositionVC?.lastCheck = lastCheck
        context.navigationController?.pushViewController(expositionVC!, animated: true)
    }

    private func routeToHighExposition(_ context: UIViewController, since: Date?) {
        highExpositionVC?.since = since
        context.navigationController?.pushViewController(highExpositionVC!, animated: true)
    }

    private func routeToPositiveExposed(_ context: UIViewController, since: Date?) {
        positiveExposedVC?.since = since
        context.navigationController?.pushViewController(positiveExposedVC!, animated: true)
    }

    private func routeToWelcome(_ context: UIViewController) {
        loadViewAsRoot(navController: context.navigationController, view: welcomeVC!)
    }

    private func loadViewAsRoot(navController: UINavigationController?, view: UIViewController, animated: Bool = false) {
        navController?.viewControllers.removeAll()
        navController?.popToRootViewController(animated: false)
        navController?.pushViewController(view, animated: animated)
    }

}
