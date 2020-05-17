//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

struct PasscodeLockConfiguration: PasscodeLockConfigurationType {

    let passcodeLength = 4
    let maximumIncorrectPasscodeAttempts = -1
}

final class PasscodeLockViewController: ViewController, PasscodeLockTypeDelegate {

    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private weak var deleteSignButton: UIButton?
    @IBOutlet private weak var touchIDButton: UIButton?
    @IBOutlet private weak var placeholdersX: NSLayoutConstraint?

    var successCallback: ((_ passCode: String) -> Void)?
    var dismissCompletionCallback: (() -> Void)?
    var animateOnDismiss: Bool
    var notificationCenter: NotificationCenter?

    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal var passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true

    private var shouldTryToAuthenticateWithBiometrics = true

    // MARK: - Initializers

    init(animateOnDismiss: Bool = true) {

        self.animateOnDismiss = animateOnDismiss

        passcodeConfiguration = PasscodeLockConfiguration()
        passcodeLock = PasscodeLock(state: EnterPasscodeState(), configuration: passcodeConfiguration)

        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(name: nibName, ofType: "nib")

        super.init(nibName: nibName, bundle: bundle)

        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        clearEvents()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        updatePasscodeView()
        deleteSignButton?.isEnabled = false

        setupEvents()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldTryToAuthenticateWithBiometrics {

            authenticateWithBiometrics()
        }
    }

    internal func updatePasscodeView() {

        titleLabel?.text = passcodeLock.state.title
        descriptionLabel?.text = passcodeLock.state.description
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
        touchIDButton?.isHidden = true
    }

    // MARK: - Events

    private func setupEvents() {

        notificationCenter?.addObserver(self,
                                        selector: #selector(appWillEnterForegroundHandler),
                                        name: UIApplication.willEnterForegroundNotification,
                                        object: nil)
        notificationCenter?.addObserver(self,
                                        selector: #selector(appDidEnterBackgroundHandler),
                                        name: UIApplication.didEnterBackgroundNotification,
                                        object: nil)
    }

    private func clearEvents() {

        notificationCenter?.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc
    func appWillEnterForegroundHandler(notification: NSNotification) {

        authenticateWithBiometrics()
    }

    @objc
    func appDidEnterBackgroundHandler(notification: NSNotification) {

        shouldTryToAuthenticateWithBiometrics = false
    }

    // MARK: - Actions

    @IBAction private func passcodeSignButtonTap(_ sender: PasscodeSignButton) {

        guard isPlaceholdersAnimationCompleted else { return }

        passcodeLock.addSign(sign: sender.passcodeSign)
    }

    @IBAction private func cancelButtonTap(_ sender: UIButton) {
        dismissPasscodeLock(lock: passcodeLock)
    }

    @IBAction private func deleteSignButtonTap(_ sender: UIButton) {
        passcodeLock.removeSign()
    }

    @IBAction private func touchIDButtonTap(_ sender: UIButton) {
    }

    private func authenticateWithBiometrics() {
    }

    internal func dismissPasscodeLock(lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {

        // if presented as modal
        if presentingViewController?.presentedViewController == self {

            dismiss(animated: animateOnDismiss) { [weak self] in
                guard let self = self else { return }
                self.dismissCompletionCallback?()

                    completionHandler?()
            }

            return

        // if pushed in a navigation controller
        } else if navigationController != nil {

            navigationController?.popViewController(animated: animateOnDismiss)
        }

        dismissCompletionCallback?()

        completionHandler?()
    }

    // MARK: - Animations

    internal func animateWrongPassword() {

        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false

        animatePlaceholders(placeholders: placeholders, toState: .Error)

        placeholdersX?.constant = -40
        view.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: { [weak self] in
            guard let self = self else { return }

                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                guard let self = self else { return }

                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(placeholders: self.placeholders, toState: .Inactive)
        })
    }

    internal func animatePlaceholders(placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {

        for placeholder in placeholders {

            placeholder.animateState(state: state)
        }
    }

    private func animatePlacehodlerAtIndex(index: Int, toState state: PasscodeSignPlaceholderView.State) {

        guard index < placeholders.count && index >= 0 else { return }

        placeholders[index].animateState(state: state)
    }

    // MARK: - PasscodeLockDelegate

    func passcodeLockDidSucceed(lock: PasscodeLockType, passcode: [String]) {
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders: placeholders, toState: .Inactive)
        successCallback?(passcode.joined())
    }

    func passcodeLockDidFail(lock: PasscodeLockType) {

        animateWrongPassword()
    }

    func passcodeLockDidChangeState(lock: PasscodeLockType) {

        updatePasscodeView()
        animatePlaceholders(placeholders: placeholders, toState: .Inactive)
        deleteSignButton?.isEnabled = false
    }

    func passcodeLock(lock: PasscodeLockType, addedSignAtIndex index: Int) {

        animatePlacehodlerAtIndex(index: index, toState: .Active)
        deleteSignButton?.isEnabled = true
    }

    func passcodeLock(lock: PasscodeLockType, removedSignAtIndex index: Int) {

        animatePlacehodlerAtIndex(index: index, toState: .Inactive)

        if index == 0 {

            deleteSignButton?.isEnabled = false
        }
    }
}
