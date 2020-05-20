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
//  FaceIDCapture.swift
//  Covid
//
//  Created by Boris Bielik on 02/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import DOT
import AVKit

final class FaceIDCapture {

    enum FaceCaptureResolution {
        case sucess(FaceCaptureImage)
        case failedToCaptureFace
        case failedToGiveCameraPermission
    }

    private weak var controller: FaceCaptureController?
    private var onFaceCapture: ((FaceCaptureResolution) -> Void)?

    func createController(completion: @escaping (FaceCaptureResolution) -> Void) -> UIViewController {
        let configuration = FaceCaptureConfiguration()
        configuration.requestTemplate = true
        configuration.lightScoreThreshold = 0.4
        configuration.requestCropImage = true
        configuration.requestFullImage = true
        configuration.cameraPosition = .front
        configuration.showCheckAnimation = false
        let controller = FaceCaptureController.create(configuration: configuration, style: .init())
        controller.delegate = self
        self.controller = controller
        onFaceCapture = completion
        return controller
    }

    func requestFaceCapture() {
        if let controller = controller {
            restartFaceCapture(in: controller)
        }
    }

    private func restartFaceCapture(in controller: FaceCaptureController) {
        controller.resetController()
        controller.requestFaceCapture()
    }
}

// MARK: Register Face
extension FaceIDCapture: FaceCaptureControllerDelegate {
    func faceCapture(_ controller: FaceCaptureController, didCapture faceCaptureImage: FaceCaptureImage) {
        onFaceCapture?(.sucess(faceCaptureImage))
    }

    func faceCaptureDidFailed(_ controller: FaceCaptureController) {
        restartFaceCapture(in: controller)
        onFaceCapture?(.failedToCaptureFace)
    }

    func faceCaptureDidLoad(_ controller: FaceCaptureController) {
        debugPrint(#function)
    }

    func faceCaptureDidAppear(_ controller: FaceCaptureController) {
        controller.requestFaceCapture()
    }

    func faceCaptureWillAppear(_ controller: FaceCaptureController) {
        debugPrint(#function)
    }

    func faceCaptureWillDisappear(_ controller: FaceCaptureController) {
        debugPrint(#function)
    }
}

// MARK: Camera permission

extension FaceIDCapture {

    func faceCaptureNoCameraPermission(_ controller: FaceCaptureController) {
        debugPrint(#function)
        guard let status = DOTHandler.authorizeCamera(onRequestAccess: { [weak self] status in
            self?.checkCameraPermission(status: status, controller: controller)
        }) else { return }

        checkCameraPermission(status: status.authorizationStatus, controller: controller)
    }

    func checkCameraPermission(status: AVAuthorizationStatus,
                               controller: FaceCaptureController) {
        FaceID().checkCameraPermission(status: status, controller: controller, onAuthorized: { [weak controller] in
            controller?.resetController()
            controller?.requestFaceCapture()
        }, onCancel: { [weak self] in
            self?.onFaceCapture?(.failedToGiveCameraPermission)
        })
    }
}
