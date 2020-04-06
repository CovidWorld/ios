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
//  FaceIDStepVerifier.swift
//  Covid
//
//  Created by Boris Bielik on 03/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import DOT
import AVKit

protocol LivenessStepDelegate: class {
    func liveness(_ step: LivenessStepCoordinator, didSucceed score: Float, capturedSegmentImages segmentImages: [SegmentImage])
    func liveness(_ step: LivenessStepCoordinator, didFailed score: Float, capturedSegmentImages segmentImages: [SegmentImage])
    func livenessdidFailedWithEyesNotDetected(_ step: LivenessStepCoordinator)
    func livenessFailed(_ step: LivenessStepCoordinator)
}

final class LivenessStepCoordinator {

    static let maxFailCount = 3
    weak var delegate: LivenessStepDelegate?
    private weak var controller: LivenessCheckController?

    private var failCount: Int = 0

    func createVerifyController(transitionType: TransitionType) -> UIViewController {
        let configuration: LivenessConfiguration
        let style: LivenessCheckStyle

        if transitionType == .move {
            configuration = LivenessConfiguration(transitionType: transitionType) {
                $0.segments = [
                    DOTSegment(targetPosition: .bottomRight, duration: 500),
                    DOTSegment(targetPosition: .bottomLeft, duration: 500),
                    DOTSegment(targetPosition: .topRight, duration: 500),
                    DOTSegment(targetPosition: .bottomRight, duration: 500),
                    DOTSegment(targetPosition: .topLeft, duration: 500),
                    DOTSegment(targetPosition: .bottomLeft, duration: 500)
                ]
                $0.minValidSegmentsCount = 5
                $0.maxFaceSizeRatio = 0.5
                $0.dotImage = #imageLiteral(resourceName: "ZZ-logo")
            }

            style = .init()
            style.background = .white

        } else {
            configuration = LivenessConfiguration(transitionType: transitionType) {
                $0.minValidSegmentsCount = 5
                $0.maxFaceSizeRatio = 0.5
            }

            style = .init()
        }

        let initialController = LivenessCheckController.create(configuration: configuration, style: style)
        initialController.delegate = self
        self.controller = initialController
        return initialController
    }

    func stopVerifying() {
        controller?.stopLivenessCheck()
    }

    func restartVerifying() {
        controller?.restartTransitionView()
        controller?.startLivenessCheck()
    }
}

extension LivenessStepCoordinator: LivenessCheckControllerDelegate {

    func livenessCheckInitialStart(_ controller: LivenessCheckController) -> Bool {
        debugPrint(#function)
        return true
    }

    func livenessCheck(_ controller: LivenessCheckController, checkDoneWith score: Float, capturedSegmentImages segmentImagesList: [SegmentImage]) {
        debugPrint(#function, segmentImagesList.count)
        controller.restartTransitionView()
        controller.startLivenessCheck()

        if score > 0.99 {
            delegate?.liveness(self, didSucceed: score, capturedSegmentImages: segmentImagesList)
        } else {
            delegate?.liveness(self, didFailed: score, capturedSegmentImages: segmentImagesList)
        }
    }

    func livenessCheck(_ controller: LivenessCheckController, stateChanged state: LivenessContextState) {
        debugPrint(#function, state)
        switch state {
        case .lost:
            failCount += 1
            if failCount == Self.maxFailCount {
                failCount = 0
                controller.restartTransitionView()
                controller.stopLivenessCheck()
                delegate?.livenessFailed(self)
            } else {
                restartVerifying()
            }
        default: break
        }
    }

    func livenessCheckNoEyesDetected(_ controller: LivenessCheckController) {
        debugPrint(#function)
        controller.stopLivenessCheck()
        self.delegate?.livenessdidFailedWithEyesNotDetected(self)
    }

    func livenessCheckNoCameraPermission(_ controller: LivenessCheckController) {
        debugPrint(#function)

        guard let status = DOTHandler.authorizeCamera(onRequestAccess: { [weak self] in
            self?.checkCameraPermission(status: $0, controller: controller)
        }) else { return }

        checkCameraPermission(status: status.authorizationStatus, controller: controller)
    }
}

extension LivenessStepCoordinator {

    func checkCameraPermission(status: AVAuthorizationStatus,
                               controller: LivenessCheckController) {
        FaceID().checkCameraPermission(status: status,
                                       controller: controller,
                                       onAuthorized: { [weak controller] in
                                        controller?.restartTransitionView()
                                        controller?.startLivenessCheck()
            }, onCancel: {  })
    }
}

extension LivenessStepCoordinator {
    func livenessCheckCameraInitFailed(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }

    func livenessCheckNoMoreSegments(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }

    func livenessCheckDidLoad(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }

    func livenessCheckWillAppear(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }

    func livenessCheckDidDisappear(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }

    func livenessCheckWillDisappear(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }

    func livenessCheckDidAppear(_ controller: LivenessCheckController) {
        debugPrint(#function)
    }
}
