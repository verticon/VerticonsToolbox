//
//  Print.swift
//
//  Created by Robert Vaessen on 12/8/15.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import Foundation

open class FileLogger {
    
    open static let instance: FileLogger? = { // Singleton
        if let fileLoggingEnabled = Bundle.main.infoDictionary?["File logging enabled"] as? Bool {
            if fileLoggingEnabled {
                return FileLogger()
            }
        }
        return nil
    }()

    // ********************************************************************

    fileprivate var queue: DispatchQueue!

    fileprivate var filePtr: UnsafeMutablePointer<FILE>!
    fileprivate var filePath: URL = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let date = formatter.string(from: Date())
        let fileName = "\(applicationName).\(date).log";
        let pathes = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        return URL(fileURLWithPath: pathes[0]).appendingPathComponent(fileName)
    }()

    fileprivate var nextKey = 0
    fileprivate var listeners: [Int : (String) -> ()] = [:]

    // ********************************************************************

    fileprivate init?() {
        filePtr = fopen(filePath.path, "a")
        if filePtr == nil {
            return nil
        }
        queue = DispatchQueue(label: "FileLoggerQueue", attributes: []);
    }

    deinit {
        if filePtr != nil {
            fclose(filePtr)
        }
    }

    // ********************************************************************

    func print(_ message: String) {
        queue.async {
            fputs(message, self.filePtr)
            
            for listener in self.listeners.values {
                listener(message)
            }

            fflush(self.filePtr)
        }
    }

    // The specified listener should already be prepared to handle the delivery of the initial contents
    // of the log file. It is possible for that delivery to occur before the addListener method returns.
    open func addListener(_ listener: @escaping (String) -> ()) -> Int {
        let key = nextKey; nextKey += 1
        queue.async {
            self.listeners[key] = listener

            do {
                let contents = try String(contentsOfFile: self.filePath.path)
                listener(contents)
            }
            catch {
                fputs("An exception occurred during the loading of the log file's initial content", self.filePtr)
            }
        }
        return key
    }
    
    open func removeListener(_ key: Int) -> Bool {
        return listeners.removeValue(forKey: key) != nil ? true : false
    }
}

public func print(_ message: String) {
    struct Statics {
        static let elapsedTime = ElapsedTime()
    }

    let text = "\(Statics.elapsedTime) \(message)\n\r"
    fputs(text, stdout)

    if let logger = FileLogger.instance {
        logger.print(text)
    }
}
