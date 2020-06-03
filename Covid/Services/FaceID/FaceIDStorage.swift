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
//  FaceIDStorage.swift
//  Covid
//
//  Created by Boris Bielik on 03/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import DOT
import SwiftyUserDefaults

final class FaceIDStorage {

    @SwiftyUserDefault(keyPath: \.referenceFace, options: [.cached, .observed])
    var referenceFaceData: [Int8]?

    @SwiftyUserDefault(keyPath: \.referenceFaceConfidence, options: [.cached, .observed])
    var referenceFaceConfidence: Double?

    func saveReferenceFace(_ faceCaptureImage: FaceCaptureImage) {
        referenceFaceData = faceCaptureImage.faceTemplate?.data

        if let fullimage = faceCaptureImage.fullImage {
            let config = FaceCaptureConfiguration()
            let image = FaceImage(image: fullimage,
                                  minFaceSizeRatio: config.minFaceSizeRatio,
                                  maxFaceSizeRatio: config.maxFaceSizeRatio)
            guard
                let confidence = FaceDetector().detectFaces(faceImage: image, maximumFaces: 1).first?.confidence,
                confidence > 0 else {
                return
            }
            referenceFaceConfidence = confidence
        }
    }
}
