//
//  File.swift
//  ClinicNotes
//
//  Created by Blezin on 08.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapManager {
    
    var centerMapCoordinate:CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.00
    
    func setupPlacemark(location: String?, clinicName: String, mapView: GMSMapView, complition: @escaping (_ coordinate: CLLocation) -> ()) {
        
        guard let location = location else {return}
        if !location.isEmpty {
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(location) { (placemarks, error) in
                
                if let error = error {
                    print(error)
                    
                    return
                }
                
                guard let placemarks = placemarks else { return }
                
                let placemark = placemarks.first
                
                let marker = GMSMarker()
                guard let placemarkLocation = placemark?.location else { return }
                let camera = GMSCameraPosition.camera(withTarget: placemarkLocation.coordinate, zoom: 15)
                marker.position = placemarkLocation.coordinate
                self.placeCoordinate = placemarkLocation.coordinate
                mapView.camera = camera
                complition(CLLocation(latitude: placemarkLocation.coordinate.latitude, longitude: placemarkLocation.coordinate.longitude))
                marker.icon = GMSMarker.markerImage(with: .black)
                marker.title = clinicName
                marker.map = mapView
                mapView.selectedMarker = marker
                
            }
            
        }
    }
    
    func createMarker(for mapView: GMSMapView, titleMarker: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.map = mapView
    }
    
}
