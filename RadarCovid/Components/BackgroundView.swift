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

class BackgroundView: UIView {

    private var gradient: CAGradientLayer?
    private var imageView: UIImageView?

    var colors: [CGColor]? {
        didSet {
            gradient = CAGradientLayer()
            gradient!.colors = colors
        }
    }

    var image: UIImage? {
        didSet {
            if let imageView = imageView {
                imageView.removeFromSuperview()
            }
            imageView = UIImageView(frame: self.bounds)
            imageView!.image = image
            draw(self.bounds)
        }
    }

    init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient?.frame = self.bounds
        imageView?.frame = self.bounds
    }

    override public func draw(_ rect: CGRect) {
        if let gradient = gradient {
            gradient.frame = self.bounds
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            if gradient.superlayer == nil {
                layer.insertSublayer(gradient, at: 0)
            }
        }

        if let imageView = imageView {
            addSubview(imageView)
            sendSubviewToBack(imageView)
            imageView.frame = self.bounds
        }

    }

}
