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
//  Hashids.swift
//  Covid
//
//  Created by Boris Kolozsi on 14/04/2020.
//

final class Hashids {
    let cHashids: UnsafeMutablePointer<hashids_t>?

    init(salt: String = "", minHashLength: Int = 0, alphabet: String = "") {
        cHashids = hashids_init3(salt.cString(using: .ascii), minHashLength, alphabet.cString(using: .ascii))
    }

    func encode(_ value: Int) -> String? {
        encodeMany([value])
    }

    func encodeMany(_ values: [Int]) -> String? {
        let count = values.count
        let vals = UnsafeMutablePointer<UInt64>.allocate(capacity: count)// [UInt64](repeating: UInt64(0), count: Int(count))
        for i in 0..<Int(count) {
            let value = UInt64(values[i])
            vals[i] = value
        }
        let estimation = hashids_estimate_encoded_size(cHashids, count, vals)
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: estimation)//[Int8](repeating: 0, count: estimation)
        if hashids_encode(cHashids, buffer, count, vals) > 0 {
            return String(cString: buffer, encoding: .ascii)
        }
        return nil
    }
}
