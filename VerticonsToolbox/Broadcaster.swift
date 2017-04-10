//
//  Broadcaster
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 4/10/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation


public protocol ListenerManagement {
    func removeListener()
}

private protocol ListenerWrapper: class {
    func deliver(event: Any)
}

open class Broadcaster<EventType> {
    
    public typealias EventHandler = (EventType) -> ()
    
    fileprivate var wrappers = [ListenerWrapper]()

    public init() {}

    public var listenerCount: Int {
        get {
            return wrappers.count
        }
    }

    public func broadcast(_ event: EventType) {
        for wrapper in self.wrappers {
            wrapper.deliver(event: event)
        }
    }
    
    open func addListener<ListenerType: AnyObject>(_ listener: ListenerType, handlerClassMethod: @escaping (ListenerType) -> EventHandler) -> ListenerManagement {
        let wrapper = Wrapper(listener: listener, handlerClassMethod: handlerClassMethod, broadcaster: self)
        wrappers.append(wrapper)
        return wrapper
    }
}

private class Wrapper<ListenerType: AnyObject, EventType> : ListenerWrapper, ListenerManagement {
    let broadcaster: Broadcaster<EventType>
    weak var listener: ListenerType?
    let handlerClassMethod: (ListenerType) -> (EventType) -> ()
    
    init(listener: ListenerType, handlerClassMethod: @escaping (ListenerType) -> (EventType) -> (), broadcaster: Broadcaster<EventType>) {
        self.broadcaster = broadcaster;
        self.listener = listener
        self.handlerClassMethod = handlerClassMethod
    }
    
    func deliver(event: Any) {
        if let listener = listener {
            handlerClassMethod(listener)(event as! EventType)
        }
        else {
            removeListener()
        }
    }
    
    func removeListener() {
        broadcaster.wrappers = broadcaster.wrappers.filter { $0 !== self }
    }
}

