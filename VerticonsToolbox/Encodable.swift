//
//  Encodable.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 3/31/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

/*
 Types announce their encodability by adopting the Encodable protocol. The creation of the
 protocol is motivated by the fact that swift's struct types cannot adopt the NSCoding protocol
 and thus NSKeyedArchiver is not available.
 */

public protocol Encodable {
    typealias Properties = Dictionary<String, Any>
    func encode() -> Properties
    init?(_ properties: Properties?)
}


// It will often occur that we have a array of objects to be encoded.
// These extensions will make the usage at the call site a bit cleaner.

extension Array where Element == Encodable.Properties {
    public func decode<T:Encodable>(type: T.Type) -> [T] {
        return compactMap{ T($0) }
    }
}

extension Array where Element : Encodable {
    public func encode() -> [Encodable.Properties] {
        return map{ $0.encode() }
    }
}


// These top level functions will save/load arrays of Encodable objecst to/from a file in the document directory.

public func saveToUserDefaults<T:Encodable>(_ objects: [T], withKey key: String) {
    UserDefaults.standard.set(objects.encode(), forKey: key)
}

public func loadFromUserDefaults<T:Encodable>(type: T.Type, withKey key: String) -> [T]? {
    return (UserDefaults.standard.array(forKey: key) as? [Encodable.Properties])?.decode(type: T.self)
}


// These top level functions will save/load arrays of Encodable objecst to/from a file in the document directory.

public func saveToFile<T:Encodable>(_ objects: [T], withName name: String) -> Bool {
    do {
        let data = NSKeyedArchiver.archivedData(withRootObject: objects.encode())
        try data.write(to: getUrl(forName: name), options: .atomic)
        return true
    } catch {
        print(error)
        return false
    }
}

public func loadFromFile<T:Encodable>(type: T.Type, withName name: String) -> [T]? {
    do {
        let data = try Data(contentsOf: getUrl(forName: name))
        if let encoded = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Encodable.Properties] {
            return encoded.decode(type: type)
        }
    } catch {
        print(error)
    }
    return nil
}

private func getUrl(forName: String) -> URL {
    return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(forName)
}

