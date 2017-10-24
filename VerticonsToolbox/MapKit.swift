//
//  MapKit.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 10/6/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import MapKit

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
}

open class ZoomingPolylineRenderer : MKPolylineRenderer {
    
    private var mapView: MKMapView!
    private var polylineWidth: Double! // Meters
    
    convenience public init(polyline: MKPolyline, mapView: MKMapView, polylineWidth: Double) {
        self.init(polyline: polyline)
        
        self.mapView = mapView
        self.polylineWidth = polylineWidth
    }
    
    override open func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        self.lineWidth = CGFloat(mapView.metersToPoints(meters: polylineWidth))
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}

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
