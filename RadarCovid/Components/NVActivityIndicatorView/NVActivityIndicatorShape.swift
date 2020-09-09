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

enum NVActivityIndicatorShape {
    case circle
    case circleSemi
    case ring
    case ringTwoHalfVertical
    case ringTwoHalfHorizontal
    case ringThirdFour
    case rectangle
    case triangle
    case line
    case pacman
    case stroke

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func layerWith(size: CGSize, color: UIColor) -> CALayer {
        let layer: CAShapeLayer = CAShapeLayer()
        var path: UIBezierPath = UIBezierPath()
        let lineWidth: CGFloat = 2

        switch self {
        case .circle:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: 0,
                        endAngle: CGFloat(2 * Double.pi),
                        clockwise: false)
            layer.fillColor = color.cgColor
        case .circleSemi:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(-Double.pi / 6),
                        endAngle: CGFloat(-5 * Double.pi / 6),
                        clockwise: false)
            path.close()
            layer.fillColor = color.cgColor
        case .ring:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: 0,
                        endAngle: CGFloat(2 * Double.pi),
                        clockwise: false)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = lineWidth
        case .ringTwoHalfVertical:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(-3 * Double.pi / 4),
                        endAngle: CGFloat(-Double.pi / 4),
                        clockwise: true)
            path.move(
                to: CGPoint(x: size.width / 2 - size.width / 2 * cos(CGFloat(Double.pi / 4)),
                            y: size.height / 2 + size.height / 2 * sin(CGFloat(Double.pi / 4)))
            )
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(-5 * Double.pi / 4),
                        endAngle: CGFloat(-7 * Double.pi / 4),
                        clockwise: false)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = lineWidth
        case .ringTwoHalfHorizontal:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(3 * Double.pi / 4),
                        endAngle: CGFloat(5 * Double.pi / 4),
                        clockwise: true)
            path.move(
                to: CGPoint(x: size.width / 2 + size.width / 2 * cos(CGFloat(Double.pi / 4)),
                            y: size.height / 2 - size.height / 2 * sin(CGFloat(Double.pi / 4)))
            )
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(-Double.pi / 4),
                        endAngle: CGFloat(Double.pi / 4),
                        clockwise: true)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = lineWidth
        case .ringThirdFour:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(-3 * Double.pi / 4),
                        endAngle: CGFloat(-Double.pi / 4),
                        clockwise: false)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = 2
        case .rectangle:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            layer.fillColor = color.cgColor
        case .triangle:
            let offsetY = size.height / 4

            path.move(to: CGPoint(x: 0, y: size.height - offsetY))
            path.addLine(to: CGPoint(x: size.width / 2, y: size.height / 2 - offsetY))
            path.addLine(to: CGPoint(x: size.width, y: size.height - offsetY))
            path.close()
            layer.fillColor = color.cgColor
        case .line:
            path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height),
                                cornerRadius: size.width / 2)
            layer.fillColor = color.cgColor
        case .pacman:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 4,
                        startAngle: 0,
                        endAngle: CGFloat(2 * Double.pi),
                        clockwise: true)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = size.width / 2
        case .stroke:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: -(.pi / 2),
                        endAngle: .pi + .pi / 2,
                        clockwise: true)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = 2
        }

        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        return layer
    }
}
