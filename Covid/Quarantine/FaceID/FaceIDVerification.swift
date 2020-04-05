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
//  FaceIDVerification.swift
//  Covid
//
//  Created by Boris Bielik on 05/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation

// MARK: Verification

extension FaceCaptureCoordinator {

    private func startVerifying() {
        coordinator = LivenessStepCoordinator()
        coordinator?.delegate = self
        if let controller = coordinator?.createVerifyController(transitionType: .move) {
            controller.title = useCase.verifyTitle
            controller.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(controller, animated: true)
            step = .faceVerification
        }
    }
}

extension FaceCaptureCoordinator: LivenessStepDelegate {

    private func validateSegmentImages(_ segmentImages: [SegmentImage]) {
        let result = faceIdValidator.validateSegmentImagesToReferenceTemplate(segmentImages)
        switch result {
        case .success:
            print("verify: success")
            completeFaceCapture(didSuccess: true)
        default:
            break
        }
    }

    func liveness(_ step: LivenessStepCoordinator, didSucceed score: Float, capturedSegmentImages segmentImages: [SegmentImage]) {
        debugPrint(#function)
        validateSegmentImages(segmentImages)
        step.stopVerifying()
    }

    func liveness(_ step: LivenessStepCoordinator, didFailed score: Float, capturedSegmentImages segmentImages: [SegmentImage]) {
        debugPrint(#function)
        validateSegmentImages(segmentImages)
    }

    func livenessdidFailedWithEyesNotDetected(_ step: LivenessStepCoordinator) {
        debugPrint(#function)
        livenessFailed(step)
    }

    func livenessFailed(_ step: LivenessStepCoordinator) {
        switch useCase {
        case .registerFace:
            askToVerifyAgain { _ in
                step.restartVerifying()
            }

        case .verifyFace:
            guard retryVerifyCount < 1 else {
                completeFaceCapture(didSuccess: false)
                return
            }

            retryVerifyCount += 1
            askToVerifyAgain { _ in
                step.restartVerifying()
            }
        }
    }
}
