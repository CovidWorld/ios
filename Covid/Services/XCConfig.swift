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
//  XCConfig.swift
//  Covid
//
//  Created by Boris Kolozsi on 14/05/2020.
//

import Foundation

class XCConfig: NSObject {
    class func string(key: String) -> String {
        let value = Bundle.main.infoDictionary?[key] as? String
        return value ?? ""
    }

    static var appName: String {
        XCConfig.string(key: "CFBundleDisplayName")
    }

    static var currentVersion: String {
        XCConfig.string(key: "CFBundleShortVersionString")
    }

    static var currentBuild: String {
        XCConfig.string(key: "CFBundleVersion")
    }

    static var bundleIdentifier: String {
        XCConfig.string(key: "CFBundleIdentifier")
    }

    static var versionWithBuildNumber: String {
        "\(currentVersion).\(currentBuild)"
    }
}
