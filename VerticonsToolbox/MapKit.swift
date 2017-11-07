//
//  MapKit.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 10/6/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import MapKit

public func enclosingRegion(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
    if coordinates.count > 0 {
        var westmost = coordinates[0].longitude
        var eastmost = westmost
        var northmost = coordinates[0].latitude
        var southmost = northmost
        
        for coordinate in coordinates {
            if coordinate.longitude < westmost { westmost = coordinate.longitude }
            else if coordinate.longitude > eastmost { eastmost = coordinate.longitude }
            if coordinate.latitude > northmost { northmost = coordinate.latitude }
            else if coordinate.latitude < southmost { southmost = coordinate.latitude }
        }
        
        let margin = 0.005
        westmost -= margin
        eastmost += margin
        northmost += margin
        southmost -= margin
        
        let latitudeDelta = northmost - southmost
        let longitudeDelta = eastmost - westmost
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let midPoint = CLLocationCoordinate2DMake(southmost + latitudeDelta/2, westmost + longitudeDelta/2)
        
        return MKCoordinateRegionMake(midPoint, span)
    }
    return nil
}

public extension MKMapView {

    public func metersToPoints(meters: Double) -> Double {
        
        let deltaPoints = 500.0
        
        let point1 = CGPoint(x: 0, y: 0)
        let coordinate1 = convert(point1, toCoordinateFrom: self)
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        
        let point2 = CGPoint(x: 0, y: deltaPoints)
        let coordinate2 = convert(point2, toCoordinateFrom: self)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        
        let deltaMeters = location1.distance(from: location2)
        
        let pointsPerMeter = deltaPoints / deltaMeters
        
        return meters * pointsPerMeter
    }

    public var userIsInteracting: Bool {
        if let gestureRecognizers = gestureView.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state != .possible {
                    return true
                }
            }
        }
        return false
    }
    
    // TODO: What's up with this? Why not just the MKMapView itself?
    public var gestureView: UIView {
        return subviews[0]
    }
}

public extension MKCoordinateRegion {

    static func * (spanMultiplier: CLLocationDegrees, region: MKCoordinateRegion) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: spanMultiplier * region.span.latitudeDelta, longitudeDelta: spanMultiplier * region.span.longitudeDelta))
    }

    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let latCheck = cos((center.latitude - coordinate.latitude) * .pi/180.0) > cos(span.latitudeDelta/2.0 * .pi/180.0);
        let lngCheck = cos((center.longitude - coordinate.longitude) * .pi/180.0) > cos(span.longitudeDelta/2.0 * .pi/180.0);
        return latCheck && lngCheck
    }

    mutating func zoomOut(to: CLLocationCoordinate2D) -> Bool {
        guard !contains(coordinate: to) else { return false }

        let multiplier = 2.25 // zoom out to include the coordinate plus a little bit more
        let deltaLat = multiplier * abs(center.latitude - to.latitude)
        let deltaLng = multiplier * abs(center.longitude - to.longitude)
 
        if deltaLat > span.latitudeDelta { span.latitudeDelta = deltaLat }
        if deltaLng > span.longitudeDelta { span.longitudeDelta = deltaLng }

        return true
    }
}

public extension MKMapRect {
    
    var midPoint: MKMapPoint {
        return MKMapPoint(x: MKMapRectGetMidX(self), y: MKMapRectGetMidY(self))
    }
    
    var corners: [MKMapPoint] {
        var corners = [MKMapPoint]()
        corners.append(origin)
        corners.append(MKMapPointMake(origin.x + size.width, origin.y))
        corners.append(MKMapPointMake(origin.x + size.width, origin.y + size.height))
        corners.append(MKMapPointMake(origin.x, origin.y + size.height))
        return corners
    }
}

public extension MKMapPoint {
    static public func == (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static public func != (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
        return !(lhs == rhs)
    }
}

public extension MKPolyline {

    // Return the point on the polyline that is the closest to the given point
    // along with the distance between that closest point and the given point.
    //
    // Thanks to:
    // http://paulbourke.net/geometry/pointlineplane/
    // https://stackoverflow.com/questions/11713788/how-to-detect-taps-on-mkpolylines-overlays-like-maps-app

    public func closestPoint(to: MKMapPoint) -> (point: MKMapPoint, distance: CLLocationDistance) {

        var closestPoint = MKMapPoint()
        var distanceTo = CLLocationDistance.infinity

        let points = self.points()
        for i in 0 ..< pointCount - 1 {
            let endPointA = points[i]
            let endPointB = points[i + 1]

            let deltaX: Double = endPointB.x - endPointA.x
            let deltaY: Double = endPointB.y - endPointA.y
            if deltaX == 0.0 && deltaY == 0.0 { continue } // Points must not be equal

            // The magic sauce. See the Paul Bourke link above.
            let closest: MKMapPoint
            let ratio: Double = ((to.x - endPointA.x) * deltaX + (to.y - endPointA.y) * deltaY) / (deltaX * deltaX + deltaY * deltaY)
            if ratio < 0.0 { closest = endPointA }
            else if ratio > 1.0 { closest = endPointB }
            else { closest = MKMapPointMake(endPointA.x + ratio * deltaX, endPointA.y + ratio * deltaY) }
            
            let distance = MKMetersBetweenMapPoints(closest, to)
            if distance < distanceTo {
                closestPoint = closest
                distanceTo = distance
            }
        }

        return (closestPoint, distanceTo)
    }

    public var boundingPolygon: MKPolygon {
        let corners = boundingMapRect.corners
        return MKPolygon(points: corners, count: corners.count)
    }

    public var  boundingRegion: MKCoordinateRegion {
        return MKCoordinateRegionForMapRect(boundingMapRect)
    }
}

public enum UserTrackingPolylineEvent {
    case userIsOnChanged(UserTrackingPolyLine)
    case userPositionChanged(UserTrackingPolyLine) // Position changes are only broadcast if the user is on
    case trackingDisabled(UserTrackingPolyLine)
}

public class UserTrackingPolyLine : Broadcaster<UserTrackingPolylineEvent> {

    public class Renderer : MKPolylineRenderer {
        
        // I had lots of trouble with the initializer; tried all kinds of things
        // /Users/Robert/Development/Apple/iOS/Learn/VerticonsToolbox/VerticonsToolbox/MapKit.swift: 49: 14: fatal error: use of unimplemented initializer 'init(overlay:)' for class 'VerticonsToolbox.ZoomingPolylineRenderer'

        public var polylineWidth = 1.0 // Meters
        public var userIsOnColor = UIColor.green
        public var userIsOffColor = UIColor.red

        private var mapView: MKMapView?

        fileprivate func subscribe(to: UserTrackingPolyLine, using: MKMapView) {
            mapView = using
            _ = to.addListener(self, handlerClassMethod: Renderer.userTrackingEventHandler)
        }

        private func userTrackingEventHandler(event: UserTrackingPolylineEvent) {
            switch event {
            case .trackingDisabled:
                userIsOn = false
            case .userIsOnChanged(let tracker):
                userIsOn = tracker.userIsOn ?? false
            default:
                break
            }
        }

        private var userIsOn: Bool = false {
            didSet {
                if userIsOn != oldValue { setNeedsDisplay() }
            }
        }
        
        override public func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            if let mapView = mapView { lineWidth = CGFloat(mapView.metersToPoints(meters: polylineWidth)) }
            strokeColor = userIsOn ? userIsOnColor : userIsOffColor
            super.draw(mapRect, zoomScale: zoomScale, in: context)
        }
    }

    private var listenerToken: ListenerManagement?

    public init(polyline: MKPolyline, mapView: MKMapView) {
        self.polyline = polyline
        renderer = Renderer(polyline: polyline)
        super.init()
        renderer.subscribe(to: self, using: mapView)
    }
    
    public private(set) var polyline: MKPolyline

    public private(set) var renderer: Renderer

    // Point is the polyline point closest to the user's actually location (as reported by Core Location).
    // Distance: is the distance from the user to that closest point.
    // Valid if tracking is enabled, else nil.
    public private(set) var userTrackingData: (point: MKMapPoint, distance: CLLocationDistance)? {
        didSet {
            guard let data = userTrackingData else { // The change to nil is not broadcast; the trackingDisabled event suffices.
                self.userIsOn = nil
                return
            }

            let userIsOn = data.distance <= trackingTolerence
            self.userIsOn = userIsOn

            if userIsOn {
                var raiseEvent = true
                if let priorData = oldValue { // If there was prior data then make sure it has changed.
                    raiseEvent = data.point != priorData.point
                }
                if raiseEvent {
                    broadcast(.userPositionChanged(self))
                }
            }
        }
    }

    // True/False if the user is/isn't within trackingTolerence meters of the polyline
    // Valid if tracking is enabled, else nil.
    public private(set) var userIsOn: Bool? {
        didSet {
            if userIsOn != oldValue && userIsOn != nil { // The change to nil is not broadcast; the trackingDisabled event suffices.
                broadcast(.userIsOnChanged(self))
            }
        }
    }

    public var trackingEnabled: Bool { return listenerToken != nil }

    public var trackingTolerence = CLLocationDistance(0) // meters

    public func enableTracking(withTolerence: CLLocationDistance) {
        trackingTolerence = withTolerence
        if listenerToken == nil {
            if let userLocation = UserLocation.instance.currentLocation {
                userTrackingData = polyline.closestPoint(to: MKMapPointForCoordinate(userLocation.coordinate))
            }
            listenerToken = UserLocation.instance.addListener(self, handlerClassMethod: UserTrackingPolyLine.userLocationEventHandler)
        }
    }

    public func disableTracking() {
        if let token = listenerToken {
            token.removeListener()
            listenerToken = nil
            userTrackingData = nil
            broadcast(.trackingDisabled(self))
       }
    }

    private func userLocationEventHandler(event: UserLocationEvent) {
        switch event {
        case .locationUpdate(let userLocation):
            userTrackingData = polyline.closestPoint(to: MKMapPointForCoordinate(userLocation.coordinate))
        default:
            break
        }
    }
}

public class UserTrackingButton : UIView {

    private let compass: MKCompassButton!
    private let trackUser: UIImageView!
    private let stateChangeHandler: (Bool) -> Void

    public init(mapView: MKMapView, stateChangeHandler: @escaping (Bool) -> Void) {
        compass = MKCompassButton(mapView: mapView)
        compass.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage(named: "TrackUser", in: Bundle(for: UserTrackingButton.self), compatibleWith: nil)
        trackUser = UIImageView(image: image)
        trackUser.bounds = compass.bounds
        trackUser.contentMode = .scaleAspectFit
        trackUser.isUserInteractionEnabled = true
        trackUser.translatesAutoresizingMaskIntoConstraints = false

        trackingUser = false

        self.stateChangeHandler = stateChangeHandler

        super.init(frame: compass.bounds)

        addSubview(compass)
        addSubview(trackUser)

        NSLayoutConstraint.activate([
            compass.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            compass.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            compass.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            compass.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            trackUser.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            trackUser.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            trackUser.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            trackUser.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)])
        
        compass.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(toggleUserTrackimg))]
        trackUser.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(toggleUserTrackimg))]

    }

    public required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented")
    }

    @objc private func toggleUserTrackimg(_ sender: UITapGestureRecognizer) {
        trackingUser = !trackingUser
        stateChangeHandler(trackingUser)
    }

    public private(set) var trackingUser: Bool {
        didSet {
            // If tracking then show the compass, else show the track user image
            compass.compassVisibility = trackingUser ? .visible : .hidden
            trackUser.isHidden = trackingUser
        }
    }
}
