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
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized && settings.alertSetting == .enabled {
            let content = UNMutableNotificationContent()
            content.body = message;
            if settings.soundSetting == .enabled { content.sound = UNNotificationSound.default }
            let request = UNNotificationRequest(identifier: "\(arc4random())", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }
}

public func alertUser(title: String?, body: String?, handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: handler))
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
        let interval = elapsedTime
        let fractions = interval.truncatingRemainder(dividingBy: 1)
        let milliseconds = Int(1000 * fractions)
        return timeFormatter.string(from: interval)! + String(format: ".%03d", milliseconds)
    }
}

extension Date {
    static func fromNow(unit: NSCalendar.Unit, value: Int) -> Date {
        return (Calendar.current as NSCalendar).date(byAdding: unit, value: value, to: Date(), options: [])!
    }
}

// Other **************************************************************************

public let applicationName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "<UnknownAppliction>"

public let runningOnSimulator = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil

public func increaseIndent(_ original: String) -> String {
    var modified = original.replacingOccurrences(of: "\n", with: "\n\t")
    modified.insert("\t", at: modified.startIndex)
    if modified.last == "\t" {
        modified.remove(at: modified.index(before: modified.endIndex))
    }
    return modified
}

public class Weak<T: AnyObject> {
    public weak var reference : T?
    public init (reference: T) {
        self.reference = reference
    }
}

public var statusBarHeight: CGFloat {
    let defaultHeight: CGFloat = 44
    guard let window = (UIApplication.shared.windows.filter{ $0.isKeyWindow }).first  else { return defaultHeight }
    return window.windowScene?.statusBarManager?.statusBarFrame.height ?? defaultHeight
}


