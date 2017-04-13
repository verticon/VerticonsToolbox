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
    
    // The addListener signature might seem odd. Here is an example usage:
    //
    //       class Listener {
    //           func eventHandler(data: (String, String)) {
    //               print("Hello \(data.0) \(data.1)")
    //           }
    //      }
    //
    //      let listener = Listener()
    //      let broadcaster = Broadcaster<(String, String)>()
    //      let manager = broadcaster.addListener(listener, handlerClassMethod: Listener.eventHandler)
    //      broadcaster.broadcast(("Chris", "Lattner")) // Prints "Hello Chris Lattner"
    //      manager.removeListener()
    //
    // addListener is taking advantage of the fact that the invocation of a method directly upon a class type
    // produces a curried function that has captured the class instance argument - have a look at the Wrapper's
    // deliver method. This is, in fact, how instance methods actually work. The reason for employing this
    // technique is to proscribe the use of closures with their inherit risk of retain cycles (do you ever forget
    // to use a capture list such as [unowned self]?). Instead of a closure with a captured self, addListener
    // receives the instance directly so that it can be stored weakly in the Wrapper, thus ensuring that all
    // will be well.
    //
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

class Listener {
    func eventHandler(data: (String, String)) {
        print("Hello \(data.0) \(data.1)")
    }
}

func test() {
let broadcaster = Broadcaster<(String, String)>()
let listener = Listener()
let manager = broadcaster.addListener(listener, handlerClassMethod: Listener.eventHandler)
broadcaster.broadcast(("Chris", "Lattner"))
manager.removeListener()
}
