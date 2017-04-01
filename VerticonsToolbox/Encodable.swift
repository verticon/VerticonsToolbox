//
//  Encodable.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 3/31/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

public protocol Encodable {
    typealias Properties = Dictionary<String, Any>
    func encode() -> Properties
    init?(_ properties: Properties?)
}

public func saveToUserDefaults<T:Encodable>(_ values: [T], withKey key: String) {
    let encodings = values.map{ $0.encode() }
    UserDefaults.standard.set(encodings, forKey: key)
}

public func loadFromUserDefaults<T:Encodable>(type: T.Type, withKey key: String) -> [T] {
    guard let encodings = UserDefaults.standard.array(forKey: key) else { return [] }
    return encodings.flatMap {
        guard let properties = $0 as? Encodable.Properties else { return nil }
        return T(properties)
    }
}
