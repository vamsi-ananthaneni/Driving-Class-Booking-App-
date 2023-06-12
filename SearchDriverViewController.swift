//
//  SearchDriverViewController.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 4/27/23.
//

import UIKit
import MapKit
import CoreLocation

class SearchDriverViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
       let regionInMeters: Double = 15000 // 15 miles
       var drivers = [MKAnnotation]()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        // Do any additional setup after loading the view.
    }
    
    func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                // Display an alert telling the user to turn on location services
            }
        }
    func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            // Display an alert telling the user to grant location access
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Display an alert telling the user that location access is restricted
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

        
        func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            centerViewOnUserLocation()
            let driverAnnotation = MKPointAnnotation()
            driverAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.01, longitude: location.coordinate.longitude + 0.01)
            driverAnnotation.title = "Driver"
            drivers.append(driverAnnotation)
            mapView.addAnnotations(drivers)
        }
        
        // MARK: - Map view delegate
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }
            let identifier = "DriverAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.image = UIImage(named: "car-icon")
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }


}
