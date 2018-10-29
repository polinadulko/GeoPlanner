//
//  PlacesOnTheMapViewController.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/25/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class PlacesOnTheMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    let locationManager = CLLocationManager()
    var mapView: GMSMapView?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    let currentLocationMarker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView = GMSMapView(frame: UIScreen.main.bounds)
        if let map = mapView {
            map.delegate = self
            map.settings.myLocationButton = true
            locationManager.distanceFilter = 300
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            view = mapView
            currentLocationMarker.title = "You're here"
            currentLocationMarker.map = map
            currentLocationMarker.appearAnimation = GMSMarkerAnimation.pop
            currentLocationMarker.icon = GMSMarker.markerImage(with: .green)
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if currentLocationCoordinate != nil {
            let camera = GMSCameraPosition.camera(withTarget: currentLocationCoordinate!, zoom: 19)
            mapView.animate(to: camera)
        }
        return true
    }
    
    //MARK:- LocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location manager")
        let lastLocation = locations.last
        if let currentLocation = lastLocation {
            currentLocationCoordinate = currentLocation.coordinate
            let camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: 19)
            if let map = mapView {
                map.animate(to: camera)
                currentLocationMarker.position = currentLocation.coordinate
            }
        }
    }

}
