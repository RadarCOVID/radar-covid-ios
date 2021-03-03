//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import RxSwift

class KeyStoreRepository {
    
    private(set) var encoder = JSONEncoder()
    private(set) var decoder = JSONDecoder()
    
    func get<T: Codable>(key: KeychainKey<T>) -> Observable<T?> {
        
        .create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            var query = self.createQuery(key)
            query[kSecReturnData as String] = kCFBooleanTrue
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            
            var data: AnyObject? = nil
            
            let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &data)
            
            switch status {
            case noErr:
                var object: T? = nil
                if let retrivedData = data as? Data {
                    object = try? JSONDecoder().decode(T.self, from: retrivedData)
                }
                observer.onNext(object)
                observer.onCompleted()
            case errSecItemNotFound:
                observer.onNext(nil)
                observer.onCompleted()
            default:
                observer.onError(KeyStoreError.secError(status))
            }
            
            return Disposables.create()
            
        }
        
    }
    
    func save<T: Codable>(key: KeychainKey<T>, value: T) -> Observable<T> {
        .create { [weak self] observer in
            
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            if let encoded = try? self.encoder.encode(value) {
                
                var query = self.createQuery(key)
                query[kSecValueData as String] = encoded
                
                var status: OSStatus = SecItemCopyMatching(query as CFDictionary, nil)
                
                switch status {
                case errSecSuccess:
                    let attributes = [kSecValueData: encoded]
                    status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
                    if status == errSecSuccess {
                        observer.onNext(value)
                        observer.onCompleted()
                    } else {
                        observer.onError(KeyStoreError.secError(status))
                    }
                    
                case errSecItemNotFound:
                    status = SecItemAdd(query as CFDictionary, nil)
                    if status == noErr {
                        observer.onNext(value)
                        observer.onCompleted()
                    } else {
                        observer.onError(KeyStoreError.secError(status))
                    }
                default:
                    observer.onError(KeyStoreError.secError(status))
                }
                
            }
            return Disposables.create()
        }
    }
    
    func delete<T: Codable>(key: KeychainKey<T>) -> Observable<Void> {
        .create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let query = self.createQuery(key)
            
            self.delete(query: query, observer: observer)
            
            return Disposables.create()
        }
    }
    
    func deleteAll() -> Observable<Void> {
        .create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword as String,
            ]
            
            self.delete(query: query, observer: observer)
            
            return Disposables.create()
        }
    }
    
    private func delete(query: [String: Any], observer: AnyObserver<Void> ) {
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        switch status {
        case noErr, errSecItemNotFound:
            observer.onNext(Void())
            observer.onCompleted()
        default:
            observer.onError(KeyStoreError.secError(status))
        }
    }
    
    
    private func createQuery<T: Codable>(_ key: KeychainKey<T>) -> [String: Any] {
         [kSecClass as String: kSecClassGenericPassword,
          kSecAttrAccount as String: key.key,
          kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]

    }
    
}

struct KeychainKey<T: Codable> {
    let key: String
    let type: T.Type
    init(key: String, type: T.Type) {
        self.key = key
        self.type = type
    }
}


enum KeyStoreError: Error {
    case secError(_ status: OSStatus)
    
    var localizedDescription: String {
        var description = "KeyStore Error!"
        switch self {
        case let .secError(status):
            description += ": " + SecCopyErrorMessageString(status, nil).debugDescription
        }
        return description
    }
}
