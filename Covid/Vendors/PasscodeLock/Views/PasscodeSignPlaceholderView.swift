//
//  PasscodeSignPlaceholderView.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

@IBDesignable
class PasscodeSignPlaceholderView: UIView {

    enum State {
        case Inactive
        case Active
        case Error
    }

    @IBInspectable var inactiveColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }

    @IBInspectable var activeColor: UIColor = UIColor.gray {
        didSet {
            setupView()
        }
    }

    @IBInspectable var errorColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 16, height: 16)

    }

    private func setupView() {

        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = activeColor.cgColor
        backgroundColor = inactiveColor
    }

    private func colorsForState(state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {

        switch state {
        case .Inactive: return (inactiveColor, activeColor)
        case .Active: return (activeColor, activeColor)
        case .Error: return (errorColor, errorColor)
        }
    }

    func animateState(state: State) {

        let colors = colorsForState(state: state)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {

                self.backgroundColor = colors.backgroundColor
                self.layer.borderColor = colors.borderColor.cgColor

            },
            completion: nil
        )
    }
}
