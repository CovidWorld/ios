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
//  IdentityViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 23/03/2020.
//

import UIKit
import SwiftyUserDefaults

final class IdentityViewController: ViewController {
    @IBOutlet private var uploadDataView: UIView!

    private var faceCaptureCoordinator: FaceCaptureCoordinator?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uploadDataView.isHidden = Defaults.covidPass == nil
        uploadDataView.layer.cornerRadius = 20
        uploadDataView.layer.masksToBounds = true

        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.isHidden = false
    }

    override func loadView() {
        super.loadView()
        uploadDataView.layer.cornerRadius = 20
        uploadDataView.layer.masksToBounds = true
    }

    @IBAction private func showCovidPass(_ sender: Any) {
        showFaceVerification()
    }

    private func showCovidPass(in navigationController: UINavigationController) {
        guard let viewController = UIStoryboard.controller(ofType: CovidPassViewController.self) else {
            return
        }

        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: Border crossing
extension IdentityViewController {

    private func showFaceVerification() {
        faceCaptureCoordinator = FaceCaptureCoordinator(useCase: .borderCrossing)
        let viewController = faceCaptureCoordinator!.startFaceCapture()
        let navigationController: UINavigationController
        if let navi = self.navigationController {
            navigationController = navi
        } else {
            navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            viewController.navigationItem.hidesBackButton = true
        }

        faceCaptureCoordinator?.navigationController = navigationController

        faceCaptureCoordinator?.onAlert = { alertControler in
            navigationController.present(alertControler, animated: true, completion: nil)
        }
        faceCaptureCoordinator?.onCoordinatorResolution = { [weak self] result in

            switch result {
            case .success(let isSuccess):
                if isSuccess {
                    self?.showCovidPass(in: navigationController)
                    return
                }
            case .failure:
                break
            }
            navigationController.dismiss(animated: true, completion: nil)
        }
        if self.navigationController != nil {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(navigationController, animated: true, completion: nil)
        }
    }
}
