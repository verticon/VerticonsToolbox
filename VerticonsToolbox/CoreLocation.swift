//
//  CoreLocation.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 4/17/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation
import CoreLocation

public func nameForAuthorizationStatus(_ status: CLAuthorizationStatus) -> String {
    switch status {
    case CLAuthorizationStatus.authorizedAlways: return "AuthorizedAlways"
    case CLAuthorizationStatus.authorizedWhenInUse: return "AuthorizedWhenInUse"
    case CLAuthorizationStatus.denied: return "Denied"
    case CLAuthorizationStatus.notDetermined: return "NotDetermined"
    case CLAuthorizationStatus.restricted: return "Restricted"
    }
}

public func nameForProximity(_ proximity: CLProximity) -> String {
    switch(proximity) {
    case .immediate: return "Immediate"
    case .near: return "Near"
    case .far: return "Far"
    case .unknown: return "Unknown"
    }
}

public func nameForRegionState(_ state: CLRegionState) -> String {
    switch state {
    case CLRegionState.unknown: return "Unknown"
    case CLRegionState.inside: return "Inside"
    case CLRegionState.outside: return "Outside"
    }
}

public enum UserLocationEvent {
    case locationUpdate(CLLocation)
    case geocodeUpdate(CLLocation)
}

public class UserLocation : Broadcaster<UserLocationEvent> {
    
    public private(set) static var instance: UserLocation?
    public static func enable() {
        if instance == nil {
            instance = CLLocationManager.locationServicesEnabled() ? UserLocation() : nil
        }
    }
    
    private class Delegate : NSObject, CLLocationManagerDelegate {
        
        fileprivate var userLocation: UserLocation!
        
        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
            switch status {
            case CLAuthorizationStatus.notDetermined:
                manager.requestWhenInUseAuthorization();
                
            case CLAuthorizationStatus.authorizedAlways:
                manager.startUpdatingLocation()
                
            case CLAuthorizationStatus.authorizedWhenInUse:
                manager.startUpdatingLocation()
                
            default:
                alertUser(title: "Location Access Not Authorized", body: "\(applicationName) will not be able to provide location related functionality.")
                break
            }
        }

        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            userLocation.broadcast(.locationUpdate(locations[locations.count - 1]))
        }
    }

    private let manager : CLLocationManager
    private let delegate : Delegate
    
    private override init() {

        manager = CLLocationManager()
        manager.distanceFilter = 5
        manager.desiredAccuracy = kCLLocationAccuracyBest

        delegate = Delegate()
        
        super.init()

        delegate.userLocation = self
        manager.delegate = delegate
    }

    public var current: CLLocation? {
        return manager.location
    }
}
