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
//  FaceIDValidator.swift
//  Covid
//
//  Created by Boris Bielik on 03/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import DOT

final class FaceIDValidator {

    let faceValidationTreshold = 85

    enum FaceIDValidatorError: Error {
        case noReferenceFaceDataFound
        case noCaptureTemplateDataFound
        case failedToVerify(scores: [NSNumber])
        case underlyingError(Error)
    }

    let storage = FaceIDStorage()
    private let faceImageVerifier = FaceImageVerifier()
    private let templateVerifier = TemplateVerifier()

    func validateCapturedFaceToReferenceTemplate(_ image: FaceCaptureImage) -> Result<NSNumber, FaceIDValidatorError> {
        guard let captureTemplate = image.faceTemplate else {
            return .failure(FaceIDValidatorError.noCaptureTemplateDataFound)
        }

        return validateProbeTemplateToReferenceTemplate(captureTemplate)
    }

    func validateProbeTemplateToReferenceTemplate(_ probeTemplate: Template) -> Result<NSNumber, FaceIDValidatorError> {
        guard let data = storage.referenceFaceData else {
            return .failure(FaceIDValidatorError.noReferenceFaceDataFound)
        }

        do {
            let score = try templateVerifier.match(referenceTemplate: Template(data: data),
                                                   probeTemplate: probeTemplate)
            debugPrint(#function, "Score of probe image is: \(score)")
            if isValidScore(score) {
                return .success(score)
            } else {
                return .failure(FaceIDValidatorError.failedToVerify(scores: [score]))
            }
        } catch {
            debugPrint(#function, "Probe image verification failed with error:", error)
            return .failure(.underlyingError(error))
        }
    }

    func validateSegmentImagesToReferenceTemplate(_ segmentImages: [SegmentImage]) -> Result<[NSNumber], FaceIDValidatorError> {
        guard let data = storage.referenceFaceData else {
            return .failure(FaceIDValidatorError.noReferenceFaceDataFound)
        }

        do {
            let probeFaceImages = segmentImages
                .compactMap { $0.dotImage.image }
                .map { FaceImage(image: $0) }
            let scores = try faceImageVerifier.match(referenceFaceTemplate: Template(data: data),
                                                     probeFaceImages: probeFaceImages)
            debugPrint(#function, "Score of captured frames is: \(scores)")

            let hasValidScore = scores
                .map { isValidScore($0) }
                .first(where: { $0 == true })
                != nil

            if hasValidScore {
                return .success(scores)
            } else {
                return .failure(FaceIDValidatorError.failedToVerify(scores: scores))
            }
        } catch {
            debugPrint(#function, "Image verification failed with error:", error)
            return .failure(.underlyingError(error))
        }
    }

    private func isValidScore(_ score: NSNumber) -> Bool {
        score.intValue > FaceID.faceIDMatchThreshold
    }
}
