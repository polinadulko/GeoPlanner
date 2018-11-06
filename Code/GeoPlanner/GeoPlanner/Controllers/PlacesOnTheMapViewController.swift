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
import CoreData

class PlacesOnTheMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    let locationManager = CLLocationManager()
    var mapView: GMSMapView?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    let currentLocationMarker = GMSMarker()
    var task: NSManagedObject?
    let cameraZoom: Float = 17
    let cameraZoomForMarker: Float = 18
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        if let reachabilityManager = networkReachabilityManager {
            if reachabilityManager.isReachable {
                mapView = GMSMapView(frame: UIScreen.main.bounds)
            }
        }
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
            currentLocationMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        }
    }
    
    //MARK:- GMSMapViewDelegate
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if currentLocationCoordinate != nil {
            let camera = GMSCameraPosition.camera(withTarget: currentLocationCoordinate!, zoom: cameraZoom)
            mapView.animate(to: camera)
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        let selectedMarkerCamera = GMSCameraPosition.camera(withTarget: marker.position, zoom: cameraZoomForMarker)
        mapView.animate(to: selectedMarkerCamera)
        return true
    }
    
    //MARK:- LocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        if let currentLocation = lastLocation {
            currentLocationCoordinate = currentLocation.coordinate
            let camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: cameraZoom)
            if let map = mapView {
                map.animate(to: camera)
                currentLocationMarker.position = currentLocation.coordinate
                if task != nil {
                    let placeFetchRequest = NSFetchRequest<Place>(entityName: "Place")
                    let predicate = NSPredicate(format: "task = %@", task!)
                    placeFetchRequest.predicate = predicate
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let managedObjectContext = appDelegate.persistentContainer.viewContext
                    do {
                        let places = try managedObjectContext.fetch(placeFetchRequest)
                        for place in places {
                            let name = place.value(forKey: "name") as! String
                            let address = place.value(forKey: "address") as! String
                            let latitude = place.value(forKey: "latitude") as! Double
                            let longitude = place.value(forKey: "longitude") as! Double
                            
                            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            marker.title = name
                            marker.snippet = address
                            marker.appearAnimation = .pop
                            marker.icon = GMSMarker.markerImage(with: UIColor.red)
                            marker.map = map
                        }
                    } catch {
                    }
                }
            }
        }
    }

}
