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
//  ServiceStatusTableViewCell.swift
//  Covid
//
//  Created by Boris Bielik on 26/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//
// swiftlint:disable private_outlet

import Foundation
import UIKit

final class ServiceStatusTableViewCell: UITableViewCell {

    var onAction: (() -> Void)?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var permissionView: IconWithCenteredLabelView!

    override func awakeFromNib() {
        super.awakeFromNib()

        permissionView.iconView.tintColor = .white
        let label = permissionView.label
        label.font = UIFont(name: "Poppins-Regular", size: 14.0)!
        label.setTextColor(UIColor.black.withAlphaComponent(0.5), forState: .highlighted)
        label.setTextColor(.white, forState: .selected)
        label.setTextColor(.white, forState: .normal)
        label.state = .normal

        permissionView.setCornerRadius(radius: 13.5,
                                       borderColor: .clear,
                                       borderWidth: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        permissionView.label.state = selected ? .selected : .normal
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        permissionView.label.state = highlighted ? .highlighted : .normal
    }
}
