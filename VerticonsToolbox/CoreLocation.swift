//
//  CoreLocation.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 4/17/17.
//  Copyright © 2017 Verticon. All rights reserved.
//
// Latitude is 0 degrees at the equater. It increases heading north, becoming +90 degrees
// at the north pole. It decreases heading south, becoming -90 degrees at the south pole.
//
// Longitude is 0 degress at the prime meridian (Greenwich, England). It increases heading
// east, becoming +180 degrees when it reaches the "other side" of the prime meridian.
// It decreases heading west, becoming -180 degrees when it reaches the other side.
//
// A CLLocationDirection specifies, in degrees, an angle relation to north. A value 0 means
// the device is pointed toward the north, 90 means it is pointed due east, 180 means it is
// pointed due south, 270 means it is pointed duw west. A negative value indicates that the
// heading could not be determined.


import Foundation
import CoreLocation
import MapKit

public func nameForAuthorizationStatus(_ status: CLAuthorizationStatus) -> String {
    switch status {
    case .authorizedAlways: return "AuthorizedAlways"
    case .authorizedWhenInUse: return "AuthorizedWhenInUse"
    case .denied: return "Denied"
    case .notDetermined: return "NotDetermined"
    case .restricted: return "Restricted"
    default: return "Unrecognized"
    }
}

public func nameForProximity(_ proximity: CLProximity) -> String {
    switch(proximity) {
    case .immediate: return "Immediate"
    case .near: return "Near"
    case .far: return "Far"
    case .unknown: return "Unknown"
    default: return "Unrecognized"
    }
}

public func nameForRegionState(_ state: CLRegionState) -> String {
    switch state {
    case .unknown: return "Unknown"
    case .inside: return "Inside"
    case .outside: return "Outside"
    }
}

public func toRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
public func toDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

// Note: I tried to define the UserLocationEvent enum within the UserLocation class (i.e. UserLocation.Event)
// but a trap occurred on the line which initializes the static instance - I think the Broadcaster caused it.
public enum UserLocationEvent {
    case authorizationUpdate(CLAuthorizationStatus)
    case locationUpdate(CLLocation)
    case geocodeUpdate(CLLocation)
    case headingUpdate(CLHeading)
}

// The UserLocation is a broadcaster hence listeners can be added to receive events (see UserLocationEvent)
public class UserLocation : Broadcaster<UserLocationEvent> {
    
    //******************************************************************************
    //                              API
    //******************************************************************************
    
    public static let instance: UserLocation = UserLocation()

    public var currentLocation: CLLocation? {
        return manager.location
    }
    
    public var currentBearing: CLLocationDirection? {
        if let bearing = manager.heading?.trueHeading, bearing >= 0 {
            return bearing
        }
        return nil
    }

    public var distanceFilter: CLLocationDistance {
        get { return manager.distanceFilter }
        set { manager.distanceFilter = newValue }
    }

    //******************************************************************************
    //                              Private
    //******************************************************************************

    private class Delegate : NSObject, CLLocationManagerDelegate {
        
        fileprivate var userLocation: UserLocation!
        
        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
            switch status {
            case .notDetermined:
                manager.requestWhenInUseAuthorization();
                return
                
            case .authorizedAlways:
                fallthrough
                
            case .authorizedWhenInUse:
                manager.distanceFilter = 1
                manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                manager.startUpdatingLocation()
                manager.startUpdatingHeading()
                
            default: break
                //alertUser(title: "Location Access Not Authorized", body: "\(applicationName) will not be able to provide location related functionality.")
            }

            userLocation.broadcast(.authorizationUpdate(status))
        }
        
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            userLocation.broadcast(.locationUpdate(locations[locations.count - 1]))
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            userLocation.broadcast(.headingUpdate(newHeading))
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error)")
        }
    }

    private let manager : CLLocationManager
    private let delegate : Delegate
    
    private override init() {

        manager = CLLocationManager()
        delegate = Delegate()
        
        super.init()

        delegate.userLocation = self
        manager.delegate = delegate // Setting the delegate results in didChangeAuthorization being called.
    }
}

public extension CLLocation {

    // Returns the positive, clockwise angle (0 -> 359.999) from this location to the other location.
    func bearing(to : CLLocation) -> Double {
        
        let lat1 = toRadians(degrees: self.coordinate.latitude)
        let lon1 = toRadians(degrees: self.coordinate.longitude)
        
        let lat2 = toRadians(degrees: to.coordinate.latitude)
        let lon2 = toRadians(degrees: to.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        var degreeBearing = toDegrees(radians: radiansBearing) // -180 to +180
        if degreeBearing < 0 { degreeBearing += 360 } // 0 to 360

        return degreeBearing
    }

    func yards(from: CLLocation) -> Double {
        let YardsPerMeter = 1.0936
        return self.distance(from: from) * YardsPerMeter
    }
    
}

extension CLLocationCoordinate2D : CustomStringConvertible {
    static public let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    static public func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return !(lhs == rhs)
    }

    public var description: String {
        return "lat \(String(format: "%.6f", latitude)), lng \(String(format: "%.6f", longitude))"
    }
}

public func makeRect(center: CLLocationCoordinate2D, span: MKCoordinateSpan) -> MKMapRect {
    let northWestCornerCoordinate = CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta/2, longitude: center.longitude - span.longitudeDelta/2)
    let southEastCornetCoordinate = CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta/2, longitude: center.longitude + span.longitudeDelta/2)
    let upperLeftCornerPoint = MKMapPoint(northWestCornerCoordinate)
    let lowerRightCornerPoint = MKMapPoint(southEastCornetCoordinate)
    return MKMapRect(x: upperLeftCornerPoint.x, y: upperLeftCornerPoint.y, width: lowerRightCornerPoint.x - upperLeftCornerPoint.x, height: lowerRightCornerPoint.y - upperLeftCornerPoint.y)
}
