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
//  FaceCaptureCoordinator.swift
//  Covid
//
//  Created by Boris Bielik on 03/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit
import DOT

final class FaceCaptureCoordinator {

    enum FaceCaptureCoordinatorStep {
        case initialised
        case onboarding
        case faceCapture
        case faceVerification
        case completion
    }

    weak var navigationController: UINavigationController?

    let faceIdCapture = FaceIDCapture()
    let faceIdValidator = FaceIDValidator()
    let useCase: FaceIDUseCase

    var onCoordinatorResolution: ((Result<Bool, Error>) -> Void)?
    var onAlert: ((UIAlertController) -> Void)?

    private(set) var step: FaceCaptureCoordinatorStep = .initialised
    private var retryCaptureCount = 0
    private var retryVerifyCount = 0

    deinit {
        debugPrint("deallocated")
    }

    init(useCase: FaceIDUseCase) {
        FaceID.initialize()
        self.useCase = useCase
    }
}

extension FaceCaptureCoordinator {

    // MARK: Onboarding

    func showOnboarding(in navigationController: UINavigationController) {
        guard let viewController = UIStoryboard.controller(ofType: FaceCaptureOnboardingViewController.self) else { return }

        viewController.onStart = { [weak self] in
            if let controller = self?.startFaceCapture() {
                navigationController.pushViewController(controller, animated: true)
            }
        }
        self.navigationController = navigationController
        navigationController.pushViewController(viewController, animated: true)
        step = .onboarding
    }

    // MARK: Face Capture

    func startFaceCapture() -> UIViewController {
        let controller = faceIdCapture.createController { [weak self] (resolution) in
            self?.processFaceCaptureResolution(resolution)
        }
        controller.navigationItem.hidesBackButton = true
        controller.title = useCase.title
        step = .faceCapture

        return controller
    }

    private func processFaceCaptureResolution(_ resolution: FaceIDCapture.FaceCaptureResolution) {
        switch resolution {
        case .sucess(let face):
            switch useCase {
            case .registerFace:
                // store reference face
                FaceIDStorage().saveReferenceFace(face)
                completeFaceCapture(didSuccess: true)
            case .verifyFace:
                verifyFace(face)
            }

        case .failedToCaptureFace:
            debugPrint("failed to capture face")

        case .failedToGiveCameraPermission:
            debugPrint("failed to give camera permission")
        }
    }

    private func verifyFace(_ face: FaceCaptureImage) {
        let result = faceIdValidator.validateCapturedFaceToReferenceTemplate(face)
        switch result {
        case .success:
            debugPrint("verify: success")
            completeFaceCapture(didSuccess: true)

        case .failure(let error):
            switch error {
            case .failedToVerify:
                handleFailedVerification()

            case .noCaptureTemplateDataFound,
                 .noReferenceFaceDataFound,
                 .underlyingError:
                debugPrint("failed to verify: ", error.localizedDescription)
            }

            debugPrint("failed to verify")
        }
    }

    private func handleFailedVerification() {
        if retryCaptureCount == 0 {
            retryCaptureCount += 1

            askToVerifyAgain { [weak self] _ in
                self?.faceIdCapture.requestFaceCapture()
            }
        } else {
            completeFaceCapture(didSuccess: false)
        }
    }

    private func askToVerifyAgain(_ action: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: "Neúspešná verifikácia",
                                                message: "Overenie Vašej tváre nebolo úspešné",
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Skúsiť znova", style: .default) { uiAction in
            action(uiAction)
        }
        let cancelAction = UIAlertAction(title: "Ukončiť verifikáciu", style: .cancel) { [weak self] _ in
            self?.completeFaceCapture(didSuccess: false)
        }

        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        onAlert?(alertController)
    }
}

// MARK: Completion
extension FaceCaptureCoordinator {

    private func completeFaceCapture(didSuccess: Bool) {
        step = .completion
        FaceCaptureCompletedViewController.show(using: { [weak self] (viewController) in
            guard let self = self else { return }
            viewController.useCase = self.useCase
            viewController.didSuccess = didSuccess
            viewController.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(viewController, animated: true)
            }, onCompletion: { [weak self] in
                self?.onCoordinatorResolution?(.success(true))
        })
    }
}
