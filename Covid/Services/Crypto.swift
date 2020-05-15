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
//  Crypto.swift
//  Covid
//
//  Created by Boris Kolozsi on 15/05/2020.
//

import Foundation
import Security

enum CryptoError: String, Error {
    case missingPrivateKey
    case invalidInput
    case keyAlreadyGenerated
}

final class Crypto {
    private static let privateKeyTag = "sk.nczi.ekarantena.private"

    class func publicKey() throws -> String? {
        try? generateKey()
        guard let privateKey = privateKey() else { throw CryptoError.missingPrivateKey }

        let publicKey = SecKeyCopyPublicKey(privateKey)

        var error: Unmanaged<CFError>?
        if let cfdata = SecKeyCopyExternalRepresentation(publicKey!, &error) {
           let data: Data = cfdata as Data
           return data.base64EncodedString()
        }
        return nil
    }

    class func sign(data: Data?) throws -> String? {
        try? generateKey()
        guard let data = data else { throw CryptoError.invalidInput }
        guard let privateKey = privateKey() else { throw CryptoError.missingPrivateKey }

        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    .ecdsaSignatureMessageX962SHA256,
                                                    data as CFData,
                                                    &error) as Data? else {
                                                        throw error!.takeRetainedValue() as Error
        }

        return signature.base64EncodedString()
    }
}

extension Crypto {
    private class func privateKey() -> SecKey? {
        guard let privateTagData = privateKeyTag.data(using: .utf8) else { return nil }
        let getQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: privateTagData,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                       kSecReturnRef as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }

        return (item as! SecKey)
    }

    private class func generateKey() throws {
        guard privateKey() == nil else { throw CryptoError.keyAlreadyGenerated }
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                                     .privateKeyUsage,
                                                     nil)

        guard let privateTagData = privateKeyTag.data(using: .utf8),
            let accessControl = access else { throw CryptoError.invalidInput }

        var attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: privateTagData,
                kSecAttrAccessControl as String: accessControl
            ]
        ]

        if Device.hasSecureEnclave {
            attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }

        var error: Unmanaged<CFError>?
        guard SecKeyCreateRandomKey(attributes as CFDictionary, &error) != nil else {
            throw error!.takeRetainedValue() as Error
        }
    }
}
