//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit

class NVActivityIndicatorAnimationBallScaleMultiple: NVActivityIndicatorAnimationDelegate {

    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0, 0.2, 0.4]

        // Scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")

        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1

        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")

        opacityAnimation.duration = duration
        opacityAnimation.keyTimes = [0, 0.05, 1]
        opacityAnimation.values = [0, 1, 0]

        // Animation
        let animation = CAAnimationGroup()

        animation.animations = [scaleAnimation, opacityAnimation]
        #if swift(>=4.2)
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        #else
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        #endif
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        // Draw balls
        for num in 0 ..< 3 {
            let circle = NVActivityIndicatorShape.circle.layerWith(size: size, color: color)
            let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                               y: (layer.bounds.size.height - size.height) / 2,
                               width: size.width,
                               height: size.height)

            animation.beginTime = beginTime + beginTimes[num]
            circle.frame = frame
            circle.opacity = 0
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}
