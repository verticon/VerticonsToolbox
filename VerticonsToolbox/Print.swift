//
//  Print.swift
//
//  Created by Robert Vaessen on 12/8/15.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import Foundation

open class FileLogger {
    
    public static let instance: FileLogger? = {
        guard let fileLoggingEnabled = Bundle.main.infoDictionary?["File logging enabled"] as? Bool, fileLoggingEnabled  else { return nil }
        return FileLogger()
    }()


    fileprivate let fileUrl: URL = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let date = formatter.string(from: Date())
        
        let name = "\(applicationName).\(date).log";
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        return URL(fileURLWithPath: path).appendingPathComponent(name)
    }()
    
    fileprivate let filePtr: UnsafeMutablePointer<FILE>!
    fileprivate let queue =  { DispatchQueue(label: "FileLoggerQueue", attributes: []) }()

    fileprivate init?() {
        filePtr = fopen(fileUrl.path, "a")
        if filePtr == nil { return nil }

        cleanUp()
    }

    deinit {
        if filePtr != nil { fclose(filePtr) }
    }

    private func cleanUp() {
        let manager = FileManager.default

        let maximumDays = 10.0
        let minimumDate = Date().addingTimeInterval(-maximumDays*24*60*60)
        
        iterateLogFiles() { logFileUrl in
            do {
                let creationDate = try manager.attributesOfItem(atPath: logFileUrl.path)[FileAttributeKey.creationDate] as! Date
                if creationDate < minimumDate { try manager.removeItem(atPath: logFileUrl.path) }
            }
            catch { fputs("Cannot remove log file \(logFileUrl.path): \(error)", self.filePtr) }
        }
    }

    private func iterateLogFiles(_ process: (URL) -> ()) {
        do {
            let manager = FileManager.default
            let documentDirUrl = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            for logFileUrl in try manager.contentsOfDirectory(at: documentDirUrl, includingPropertiesForKeys: nil) {
                let logFileName = logFileUrl.lastPathComponent
                if logFileName.hasPrefix(applicationName) && logFileName.hasSuffix("log") { process(logFileUrl) }
            }
        }
        catch { fputs("Cannot iterate log files: \(error)", self.filePtr) }
    }

    public func package() -> [String : Data] {
        var package = [String : Data]()
        iterateLogFiles() { logFileUrl in
            package[logFileUrl.lastPathComponent] = {
                do {  return try Data(contentsOf: logFileUrl) }
                catch { return "Cannot create Data from \(logFileUrl): \(error)".data(using: .utf8) ?? Data() }
            }()
        }
        return package
    }

    public func print(_ message: String) {
        queue.async {
            fputs(message, self.filePtr)
            for listener in self.listeners.values { listener(message) }
            fflush(self.filePtr)
        }
    }

    // *******************************************************
    // Listeners
    // *******************************************************

    fileprivate var nextKey = 0
    fileprivate var listeners: [Int : (String) -> ()] = [:]

    // The specified listener should already be prepared to handle the delivery of the initial contents
    // of the log file. It is possible for that delivery to occur before the addListener method returns.
    open func addListener(_ listener: @escaping (String) -> ()) -> Int {
        let key = nextKey; nextKey += 1
        queue.async {
            self.listeners[key] = listener
            do { listener(try String(contentsOfFile: self.fileUrl.path)) }
            catch { fputs("Cannot read log file \(self.fileUrl.path): \(error)", self.filePtr) }
        }
        return key
    }
    
    open func removeListener(_ key: Int) -> Bool {
        return listeners.removeValue(forKey: key) != nil ? true : false
    }
}

private let elapsedTime = ElapsedTime()
private let consoleLoggingEnabled = Bundle.main.infoDictionary?["Console logging enabled"] as? Bool

public func print(_ message: String) {
    
    let text = "\(elapsedTime) \(message)\n\r"

    var consoleEnabled = true
    if let enabled = consoleLoggingEnabled { consoleEnabled = enabled }
    if consoleEnabled { fputs(text, stdout) }

    FileLogger.instance?.print(text)
}
