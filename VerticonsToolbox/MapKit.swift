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

public class ZoomingPolylineRenderer : MKPolylineRenderer {
    
    private var mapView: MKMapView!
    private var polylineWidth: Double! // Meters
    
    convenience public init(polyline: MKPolyline, mapView: MKMapView, polylineWidth: Double) {
        self.init(polyline: polyline)
        
        self.mapView = mapView
        self.polylineWidth = polylineWidth
    }
    
    override public func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        self.lineWidth = CGFloat(mapView.metersToPoints(meters: polylineWidth))
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}

