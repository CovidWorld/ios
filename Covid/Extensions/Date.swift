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
//  Date.swift
//  Covid
//
//  Created by Boris Bielik on 29/05/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation

extension Date {
    struct Formatters {
        private static var _dateAndTime: DateFormatter?
        static var dateAndTime: DateFormatter {
            if _dateAndTime == nil {
                _dateAndTime = DateFormatter()
                _dateAndTime!.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMMMyyyyhm", options: 0, locale: Locale.current)
            }
            return _dateAndTime!
        }
    }

    ///shows date (Aug 19, 2015)
    func formattedDateAndYear() -> String {
        return Formatters.dateAndTime.string(from: self)
    }
}

