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
//  FaceCaptureCompletedViewController.swift
//  Covid
//
//  Created by Boris Bielik on 04/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

extension FaceCaptureCompletedViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "faceCaptureComplete"
}

final class FaceCaptureCompletedViewController: UIViewController {

    var useCase: FaceIDUseCase = .registerFace
    var didSuccess = true

    private var onCompletion: (() -> Void)?

    @IBOutlet private weak var thankYouLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    static func show(using presentationBlock: @escaping (FaceCaptureCompletedViewController) -> Void, onCompletion: @escaping () -> Void) {
        if let viewController = UIStoryboard.controller(ofType: Self.self) {
            viewController.onCompletion = onCompletion
            presentationBlock(viewController)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thankYouLabel.text = useCase.completionTitle(didSuccess: didSuccess)
        descriptionLabel.text = useCase.completionDescription(didSuccess: didSuccess)
        actionButton.backgroundColor = useCase.actionButtonColor
        iconView.image = useCase.completionIcon(didSuccess: didSuccess)

        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction private func faceCaptureCompleted(_ sender: Any) {
        actionButton.isEnabled = false
        onCompletion?()

        guard useCase != .borderCrossing else { return }
        activityIndicator.startAnimating()
    }
}
