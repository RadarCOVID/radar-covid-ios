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
extension UIView {
    
    func showTransparentBackground
        (withColor color: UIColor,
         alpha: CGFloat,
         _ message: String? = nil,
         _ attributedMessage: NSAttributedString? = nil,
         _ textColor: UIColor? = nil,
         _ completion: (() -> Void)? = nil,
         tagTransparentView: Int = 1111,
         tagMenssagetView: Int = 1122) {
        
        let transparentView = Bundle.main.loadNibNamed(
            "TransparentView",
            owner: self,
            options: nil
        )?.first as? TransparentView

        transparentView?.frame = self.frame
        transparentView!.backgroundColor = color
        transparentView!.alpha = 0
        transparentView!.tag = tagTransparentView
        transparentView!.isAccessibilityElement = true
        
        if let messageView = transparentView?.messageView {
            if let regularText = message {
                messageView.text = regularText
            } else {
                messageView.attributedText = attributedMessage
            }
            messageView.textColor = textColor ?? UIColor.black
            messageView.font = UIFont(name: "Helvetica Neue", size: 26)
            messageView.numberOfLines = 0
            messageView.minimumScaleFactor = 0.1
            messageView.tag = tagMenssagetView
            messageView.textAlignment = .center
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.addSubview(transparentView!)
            transparentView?.fadeIn(alpha, { _ in
                if let completion = completion {
                    completion()
                }
            })
        }
    }

    func removeTransparentBackGround(tagTransparentView: Int = 1111,
                                     tagMenssagetView: Int = 1122) {
        DispatchQueue.main.async { [weak self] in
            for view in self?.subviews ?? [] {
                if view.tag == tagTransparentView || view.tag == tagMenssagetView {
                    view.fadeOut { (_) in
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }

    func showLoading() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light )
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 99
        DispatchQueue.main.async { [weak self] in
            blurEffectView.fadeIn()
            self?.addSubview(blurEffectView)
        }
        let loader = NVActivityIndicatorView(
            frame: CGRect(x: self.center.x-65, y: self.center.y-65, width: 130, height: 130),
            type: NVActivityIndicatorType.ballScaleMultiple,
            color: UIColor.twilight
        )
            DispatchQueue.main.async { [weak self] in
                loader.startAnimating()
                self?.addSubview(loader)
            }
    }

    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            for view in self?.subviews ?? [] {
                if view is NVActivityIndicatorView ||
                    view.tag == 99 ||
                    view.tag == 1111 ||
                    view.tag == 1122 {
                    
                    view.fadeOut { (_) in
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    func fadeIn(_ alpha: CGFloat = 1.0, _ completion: ((_ err: Bool) -> Void)? = nil ) {
        self.alpha = 0.0

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = alpha
        }, completion: completion)
    }

    func fadeOut(callBack: ((_: Bool) -> Void)? = nil ) {
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: {
                self.alpha = 0.0
            }, completion: callBack)
    }
    
    func setShadow() {
        self.layer.shadowColor = UIColor.powderBlue.cgColor
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.masksToBounds = false
    }
    
  
}
