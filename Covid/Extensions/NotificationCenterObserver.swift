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
//  NotificationCenterObserver.swift
//
//  Created by Boris Bielik on 09/08/2019.
//
//

import Foundation

struct NotificationDescriptor<T> {
    let name: Notification.Name
    let convert: (Notification) -> T
}

final class NotificationToken {
    private let token: NSObjectProtocol
    private let notificationCenter: NotificationCenter

    deinit {
        cancel()
    }

    init(token: NSObjectProtocol, notificationCenter: NotificationCenter) {
        self.token = token
        self.notificationCenter = notificationCenter
    }

    func cancel() {
        notificationCenter.removeObserver(token)
    }
}

extension NotificationCenter {

    func addObserver(forName name: Notification.Name, closure: @escaping (Notification) -> Void) -> NotificationToken {
        let token = addObserver(forName: name, object: nil, queue: nil, using: closure)
        return NotificationToken(token: token, notificationCenter: self)
    }

    func addObserver<T>(descriptor: NotificationDescriptor<T>, using block: @escaping (T) -> Void) -> NotificationToken {
        let token = addObserver(forName: descriptor.name, object: nil, queue: nil) { notification in
            block(descriptor.convert(notification))
        }
        return NotificationToken(token: token, notificationCenter: self)
    }
}

protocol NotificationCenterObserver: class {

    var notificationTokens: [NotificationToken] { get set }

    func unobserveNotifications()
    func observeNotification(withName name: NSNotification.Name, closure: @escaping (Notification) -> Void)
}

extension NotificationCenterObserver {

    func unobserveNotifications() {
        notificationTokens.forEach { $0.cancel() }
        notificationTokens.removeAll()
    }

    func observeNotification(withName name: NSNotification.Name, closure: @escaping (Notification) -> Void) {
        let token = NotificationCenter.default.addObserver(forName: name, closure: closure)
        notificationTokens.append(token)
    }
}
