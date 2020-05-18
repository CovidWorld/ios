//
//  PasscodeSignButton.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

@IBDesignable
class PasscodeSignButton: UIButton {

    @IBInspectable
    var passcodeSign: String = "1"

    @IBInspectable
    var borderColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    var borderRadius: CGFloat = 30 {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    var highlightBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)

        setupView()
        setupActions()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        setupActions()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 60, height: 60)

    }

    private var defaultBackgroundColor = UIColor.clear

    private func setupView() {

        layer.borderWidth = 1
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor

        if let backgroundColor = backgroundColor {

            defaultBackgroundColor = backgroundColor
        }
    }

    private func setupActions() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
    }

    @objc func handleTouchDown() {

        animateBackgroundColor(color: highlightBackgroundColor)
    }

    @objc func handleTouchUp() {

        animateBackgroundColor(color: defaultBackgroundColor)
    }

    private func animateBackgroundColor(color: UIColor) {

        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.backgroundColor = color
            },
            completion: nil
        )
    }
}
