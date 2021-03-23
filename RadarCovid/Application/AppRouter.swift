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
    case qrScanner
    case qrResult
    case checkedIn
    case checkOut
    case checkOutConfirmation
    case qrError
    case venueList
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
                routeToRoot(context, urlSchemeRedirect: param.first as? [Routes], paramsUrlScheme: param[1] as? [Any?])
            } else {
                routeToRoot(context, urlSchemeRedirect: nil, paramsUrlScheme: [])
            }
        case .welcome:
            routeToWelcome(context)
        case .onBoarding:
            routeToOnboarding(context)
        case .home:
            routeToHome(context, parameters)
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
                routeToMyHealthStep1(context, covidCode: param.first as? String ?? "")
            } else {
                routeToMyHealthStep1(context)
            }
        case .myHealthStep2:
            if let param = parameters,
               param.count >= 2 {
                routeToMyHealthStep2(context, codeString: param.first as? String ?? "", dateNotificationPositive: param[1] as? Date)
            }
            
        case .myHealthReported:
            routeToMyHealthReported(context)
        case .healthyExposition:
            routeToHealthyExposition(context, expositionInfo: parameters?.first as! ExpositionInfo)
        case .highExposition:
            let isContact = parameters!.count == 2 ? parameters![1] : true
            routeToHighExposition(context, expositionInfo: parameters?.first as! ExpositionInfo, isContact: (isContact ?? true)  as! Bool)
        case .positiveExposed:
            routeToPositiveExposed(context, expositionInfo: parameters?.first as! ExpositionInfo)
        case .changeLanguage:
            routeToRootAndResetView(context, parameters)
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
        case .qrScanner:
            routeToQrScanner(context)
        case .qrResult:
            routeToQrResult(context, qrCode: parameters?.first as? String)
        case .checkedIn:
            routeToCheckedIn(context)
        case .checkOut:
            routeToCheckOut(context)
        case .checkOutConfirmation:
            routeToCheckoutConfirmation(context)
        case .qrError:
            routeToQrError(context, error: parameters?.first as? Error)
        case .venueList:
            routeToVenueList(context)
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
    
    private func routeToRootAndResetView(_ context: UIViewController, _ parameters: [Any?]?) {
        let rootVC = AppDelegate.shared?.injection.resolve(RootViewController.self)!
        if let param = parameters, param.count > 0 {
            rootVC?.selectTabType = param.first as? UIViewController.Type
        }
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
        loadViewAsRoot(navController: context.navigationController, view: unsupportedOSVC!)
    }
    
    private func routeToHome(_ context: UIViewController, _ parameters: [Any?]?) {
        let tabBarController = AppDelegate.shared?.injection.resolve(TabBarController.self)!
        if let param = parameters, param.count > 0 {
            tabBarController!.selectTabType = param.first as? UIViewController.Type
        }

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

    private func routeToHealthyExposition(_ context: UIViewController, expositionInfo: ExpositionInfo) {
        let expositionVC = AppDelegate.shared?.injection.resolve(HealthyExpositionViewController.self)!
        expositionVC?.expositionInfo = expositionInfo
        context.navigationController?.pushViewController(expositionVC!, animated: true)
    }

    private func routeToHighExposition(_ context: UIViewController, expositionInfo: ExpositionInfo, isContact: Bool) {
        let highExpositionVC = AppDelegate.shared?.injection.resolve(HighExpositionViewController.self)!
        highExpositionVC?.expositionInfo = expositionInfo
        highExpositionVC?.isContact = isContact
        context.navigationController?.pushViewController(highExpositionVC!, animated: true)
    }

    private func routeToPositiveExposed(_ context: UIViewController, expositionInfo: ExpositionInfo) {
        let positiveExposedVC = AppDelegate.shared?.injection.resolve(PositiveExposedViewController.self)!
        positiveExposedVC?.expositionInfo = expositionInfo
        context.navigationController?.pushViewController(positiveExposedVC!, animated: true)
    }

    private func routeToWelcome(_ context: UIViewController) {
        let welcomeVC = AppDelegate.shared!.injection.resolve(WelcomeViewController.self)!
        loadViewAsRoot(navController: context.navigationController, view: welcomeVC)
    }
    
    private func routeToQrScanner(_ context: UIViewController) {
        let qrScannerVC = AppDelegate.shared!.injection.resolve(QrScannerViewController.self)!
        context.navigationController?.pushViewController(qrScannerVC, animated: true)
    }
    
    private func routeToQrResult(_ context: UIViewController, qrCode: String?) {
        let qrResultVC = AppDelegate.shared!.injection.resolve(QrResultViewController.self)!
        qrResultVC.qrCode = qrCode
        context.navigationController?.pushViewController(qrResultVC, animated: true)
    }
    
    private func routeToCheckedIn(_ context: UIViewController) {
        let checkedInVC = AppDelegate.shared!.injection.resolve(CheckedInViewController.self)!
        context.navigationController?.pushViewController(checkedInVC, animated: true)
    }
    
    private func routeToCheckOut(_ context: UIViewController) {
        let vc = AppDelegate.shared!.injection.resolve(CheckOutViewController.self)!
        context.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func routeToCheckoutConfirmation(_ context: UIViewController) {
        let vc = AppDelegate.shared!.injection.resolve(CheckOutConfirmationViewController.self)!
        context.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func routeToQrError(_ context: UIViewController, error: Error?) {
        let vc = AppDelegate.shared!.injection.resolve(QrErrorViewController.self)!
        vc.error = error
        context.navigationController?.pushViewController(vc, animated: true)
    }
    private func routeToVenueList(_ context: UIViewController) {
        let vc = AppDelegate.shared!.injection.resolve(VenueListViewController.self)!
        context.navigationController?.pushViewController(vc, animated: true)
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
        
        if let root = from.navigationController?.viewControllers.first, root.isKind(of: TabBarController.self) {
            from.navigationController?.popToRootViewController(animated: animated)
        } else {
            route(to: .home, from: from)
        }
        
        parentVC = nil
    }

    func pop(from: UIViewController, animated: Bool) {
        from.navigationController?.popViewController(animated: animated)
        parentVC?.viewWillAppear(animated)
        parentVC = nil
    }

}
