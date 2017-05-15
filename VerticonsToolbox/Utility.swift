//
//  Utility.swift
//
//  Created by Robert Vaessen on 10/4/15.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import UIKit
import UserNotifications

// Synchronization ****************************************************************************

public func lockObject<T>(_ object: AnyObject, andExecuteCode code: () -> T?) -> T? {
    objc_sync_enter(object)
    defer { objc_sync_exit(object) }
    return code()
}

public var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

public var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
}

public var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
}

public var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
}

public var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
}

// Data **************************************************************************

// TODO: Rethink the forced unwrapping of the String initializers
public extension Data {

    public init(with: String, using: String.Encoding = .utf8) {
        self.init()
        self.append(with.data(using: using)!)
        self.append(0)
    }
    
    public init(with: [String], using: String.Encoding = .utf8) {
        self.init()
        with.forEach { self.append(Data(with: $0, using: using)) }
    }
    
    public func toString(encoding: String.Encoding = .utf8) -> String {
        return String(data: self, encoding: encoding)!
    }
            
    public func toStringArray(encoding: String.Encoding = .utf8) -> [String] {
        
        return withUnsafeBytes { (ptr: UnsafePointer<Int8>) in
            
            var strings = [String]()
            
            var start = ptr
            for offset in 0 ..< self.count {
                
                let current = ptr + offset
                
                if current != start && current.pointee == 0 {
                    // if we cannot decode the string, append a unicode replacement character
                    // feel free to handle this another way.
                    strings.append(String(cString: start, encoding: encoding) ?? "\u{FFFD}")
                    start = current + 1
                }
            }
            
            return strings
        }
    }
    
    public func toHexString(seperator: String) -> String {
        return self.map { String(format: "%02hhX", $0) }.joined(separator: seperator)
    }
}

public extension Data {
    
    public init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    /* From Data definition:
     func withUnsafeBytes<ResultType, ContentType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType
     */
    public func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    public init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }
    
    public func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}

// User Notifications **************************************************************************
/*
 let content = UNMutableNotificationContent()
 content.title = NSString.localizedUserNotificationStringForKey("Hello!", arguments: nil)
 content.body = NSString.localizedUserNotificationStringForKey("Hello_message_body", arguments: nil)
 content.sound = UNNotificationSound.defaultSound()
 
 // Deliver the notification in five seconds.
 let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
 let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
 
 // Schedule the notification.
 let center = UNUserNotificationCenter.currentNotificationCenter()
 center.addNotificationRequest(request)
 */
public func notifyUser(_ message:  String) {
    if hasNotifyPermission() {
        let content = UNMutableNotificationContent()
        content.body = message;
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: "\(arc4random())", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

public func hasNotifyPermission() -> Bool {
    let currentSettings = UIApplication.shared.currentUserNotificationSettings
    return currentSettings!.types.contains(.alert) && currentSettings!.types.contains(.sound)
}

public func alertUser(title: String?, body: String?, handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: handler))
    alert.display()
}

// Time and Date **************************************************************************

public class LocalTime {
    fileprivate static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy HH:mm:ss")
        return formatter
    }()
    
    public class var text : String {
        return dateFormatter.string(from: Date())
    }
}

public class ElapsedTime : CustomStringConvertible {
    fileprivate let startTime = Date()
    fileprivate let timeFormatter = DateComponentsFormatter()
    
    init() {
        timeFormatter.calendar = Calendar.current;
        timeFormatter.zeroFormattingBehavior = [.pad]
        timeFormatter.allowedUnits = [.hour, .minute, .second]
    }
    
    public var elapsedTime : TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
    
    public var description : String {
        return timeFormatter.string(from: elapsedTime)!
    }
}

extension Date {
    static func fromNow(unit: NSCalendar.Unit, value: Int) -> Date {
        return (Calendar.current as NSCalendar).date(byAdding: unit, value: value, to: Date(), options: [])!
    }
}

// Other **************************************************************************

public var applicationName: String = {
    struct Name {
        static let value = Name()
        
        let text: String
        
        init() {
            if let name = Bundle.main.infoDictionary?["CFBundleName"] {
                text = name as! String
            }
            else {
                text = "<UnknownAppliction>"
            }

        }
    }

    return Name.value.text
}()

public func increaseIndent(_ original: String) -> String {
    var modified = original.replacingOccurrences(of: "\n", with: "\n\t")
    modified.insert("\t", at: modified.startIndex)
    if modified.characters.last == "\t" {
        modified.remove(at: modified.characters.index(before: modified.endIndex))
    }
    return modified
}

public enum NumericType {

    case int8
    case uint8
    case int16
    case uint16
    case int32
    case uint32
    case int64
    case uint64
    case float
    case double

    public var type: Any {
        switch self {
        case .int8: return Int8.self
        case .uint8: return UInt8.self
        case .int16: return Int16.self
        case .uint16: return UInt16.self
        case .int32: return Int32.self
        case .uint32: return UInt32.self
        case .int64: return Int64.self
        case .uint64: return UInt64.self
        case .float: return Float.self
        case .double: return Double.self
        }
    }
    
    public var name: String {
        switch self {
        case .int8: return "\(Int8.self)"
        case .uint8: return "\(UInt8.self)"
        case .int16: return "\(Int16.self)"
        case .uint16: return "\(UInt16.self)"
        case .int32: return "\(Int32.self)"
        case .uint32: return "\(UInt32.self)"
        case .int64: return "\(Int64.self)"
        case .uint64: return "\(UInt64.self)"
        case .float: return "\(Float.self)"
        case .double: return "\(Double.self)"
        }
    }
    
    public struct Wrapper : CustomStringConvertible {
        public let type: NumericType
        public var description: String { return type.name }
    }

    public static let all: [Wrapper] = {
        var wrappers = [Wrapper]()
        
        wrappers.append(Wrapper(type: .int8))
        wrappers.append(Wrapper(type: .uint8))
        wrappers.append(Wrapper(type: .int16))
        wrappers.append(Wrapper(type: .uint16))
        wrappers.append(Wrapper(type: .int32))
        wrappers.append(Wrapper(type: .uint32))
        wrappers.append(Wrapper(type: .int64))
        wrappers.append(Wrapper(type: .uint64))
        wrappers.append(Wrapper(type: .float))
        wrappers.append(Wrapper(type: .double))
        
        return wrappers
    }()
    
}
