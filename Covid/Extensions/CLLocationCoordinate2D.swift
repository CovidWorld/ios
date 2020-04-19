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

import Foundation
import MapKit

extension CLLocationCoordinate2D: CustomStringConvertible {
    public var description: String {
        "\(latitude), \(longitude)"
    }

}

extension CLLocationCoordinate2D {
    func coordinateWithOffset(usingLatitudeDelta latitudeDelta: CLLocationDegrees,
                              longitudeDelta: CLLocationDegrees) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude + latitudeDelta,
                               longitude: longitude + longitudeDelta)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        (fabs(lhs.latitude - rhs.latitude) < .ulpOfOne) && (fabs(lhs.longitude - rhs.longitude) < .ulpOfOne)
    }

    var hash: Int {
        Int(latitude * longitude)
    }
}

extension CLLocationCoordinate2D {
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
