/*-
* Copyright (c) 2020 Sygic
*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
 * The above copyright notice and this permission notice shall be included in
* copies or substantial portions of the Software.
*
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/
//
//  UIView+CornerRadius.swift
//  Covid
//
//  Created by Boris Bielik on 26/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    @discardableResult func setCornerRadius(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) -> CAShapeLayer {
        let rect = self.bounds

        let maskPath = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: .allCorners,
                                    cornerRadii: CGSize(width: radius, height: radius))

        // Create the shape layer and set its path
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath

        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer

        //Create path for border
        let borderPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))

        // Create the shape layer and set its path
        let borderLayer = CAShapeLayer()

        borderLayer.frame = rect
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = borderWidth * UIScreen.main.scale

        //Add this layer to give border.
        self.layer.addSublayer(borderLayer)

        return borderLayer
    }

}
