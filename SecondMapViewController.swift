//
//  SecondMapViewController.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 4/5/23.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class SecondMapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, UISearchResultsUpdating, CLLocationManagerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UIDatePicker!
    var searchController: UISearchController!
    var matchingItems: [MKMapItem] = []
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var destinationLocation: CLLocation?
    var selectedTime: Date?
    var price: Double?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for location"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Show the user's location on the map
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Request permission to access the user's location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Set the current location
        if let userLocation = locationManager.location {
            currentLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        }
        // Set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func timeSelected(_ sender: UIDatePicker) {
        // Fetch the selected time from the UIDatePicker
            let selectedTime = sender.countDownDuration
            
            // Convert selected time to minutes
            let selectedTimeInMinutes = selectedTime / 60
            
            // Calculate the remaining time in minutes
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute], from: Date(), to: Date(timeIntervalSinceNow: selectedTime))
            guard let minutes = components.minute else { return }
            
            // Initialize price to a default value
            var price: Double = 0.0
            
            // Update the price if necessary
            if let destinationLocation = destinationLocation, let currentLocation = currentLocation {
                let distanceInMeters = destinationLocation.distance(from: currentLocation)
                let distanceInMiles = distanceInMeters / 1609.344
                
                // Check if the distance is greater than 15 miles
                var pricePerMinute = 30.0 / 60.0
                if distanceInMiles > 15 {
                    // Calculate the extra charge
                    let extraCharge = (distanceInMiles - 15) * 0.9
                    
                    // Add the extra charge to the price per minute
                    pricePerMinute += extraCharge / Double(selectedTimeInMinutes)
                    
                }
                
                // Calculate the price based on the selected time and price per minute
                let totalMinutes = selectedTimeInMinutes + Double(minutes) // Type cast minutes to Double
                price = pricePerMinute * totalMinutes
            }
            
        // Get a reference to the Firestore database
        let db = Firestore.firestore()

        // Update the collection name to "timeSaved" instead of "userTime"
        let docRef = db.collection("timeSaved").document()

        // Define the data to be saved
        let data: [String: Any] = [
            "appointmentTime": selectedTimeInMinutes,
            "cost": price,
            "created": FieldValue.serverTimestamp()
        ]

        // Save the data to Firestore
        docRef.setData(data) { error in
            if let error = error {
                print("Error saving user time data: \(error.localizedDescription)")
            } else {
                print("User time data saved successfully")
            }
        }

    }

            func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check if the user has granted permission to access their location
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update the user's current location on the map
        guard let userLocation = locations.last else { return }
        
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
        
        // Set the current location
        currentLocation = userLocation
    }
    
    @IBAction func booknowTap(_ sender: UIButton) {
        // Fetch the selected time from the UIDatePicker (assuming it's correctly connected in your storyboard or XIB file)
            let selectedTime = timeLabel.countDownDuration
        // Convert selected time to minutes
       let _ = selectedTime / 60

            // Calculate the remaining time in minutes
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute], from: Date(), to: Date(timeIntervalSinceNow: selectedTime))
            guard let minutes = components.minute else { return }

            // Check if the selected time is within the allowed range (30 mins to 2 hours)
            if minutes < 30 {
                showAlert(title: "Invalid time", message: "Please select a time that is at least 30 minutes from now.")
                return
            } else if minutes > 120 {
                showAlert(title: "Invalid time", message: "Please select a time that is within the next 2 hours.")
                return
            }

            // Calculate the price based on the selected time
            var price = 0.0
            var pricePerMinute = 30.0 / 60.0
            price = pricePerMinute * Double(minutes)

            // Check if a destination location is selected
        if let destinationLocation = destinationLocation, let currentLocation = currentLocation {
            // Calculate the distance in miles
            let distanceInMeters = destinationLocation.distance(from: currentLocation)
            let distanceInMiles = distanceInMeters / 1609.344
            
            // Check if the distance is greater than 15 miles
            if distanceInMiles > 15 {
                // Calculate the extra charge
                let extraCharge = (distanceInMiles - 15) * 0.9
                
                // Add the extra charge to the price per minute
                pricePerMinute += extraCharge / Double(minutes)
                
                // Update the price based on the updated price per minute
                price = pricePerMinute * Double(minutes)
            }
        }
        
            // Instantiate the "PaymentViewController" from the storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let paymentViewController = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController else {
                fatalError("Unable to instantiate Payment View Controller.")
            }

            // Pass the price to the "PaymentViewController"
            paymentViewController.price = price
        // Store the price in Firestore
        let db = Firestore.firestore()
        let priceData: [String: Any] = [
            "price": price,
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("prices").addDocument(data: priceData) { error in
            if let error = error {
                print("Error adding price to Firestore: \(error.localizedDescription)")
            } else {
                print("Price added to Firestore successfully!")
            }
        }

            // Push the "PaymentViewController" onto the navigation stack
            navigationController?.pushViewController(paymentViewController, animated: true)
        }
    

   
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        // Wait until the user has finished typing before performing the search
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch(_:)), object: searchText)
        perform(#selector(performSearch(_:)), with: searchText, afterDelay: 0.5)
    }
    @objc func performSearch(_ searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { [self] (response, error) in
            guard let response = response else { return }
            
            self.matchingItems = response.mapItems
            
            let annotations = self.mapView.annotations
            self.mapView.removeAnnotations(annotations)
            
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                
                self.mapView.addAnnotation(annotation)
            }
            
            if let userLocation = self.locationManager.location {
                let sourceLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                let destinationLocation = CLLocation(latitude: response.mapItems[0].placemark.coordinate.latitude, longitude: response.mapItems[0].placemark.coordinate.longitude)
                let distance = sourceLocation.distance(from: destinationLocation) / 1609.34 // Convert meters to miles
                
                // Save location data to Firestore
                let db = Firestore.firestore()
                let docRef = db.collection("locations").document()
                let data: [String: Any] = [
                    "userLatitude": userLocation.coordinate.latitude,
                    "userLongitude": userLocation.coordinate.longitude,
                    "destinationLatitude": response.mapItems[0].placemark.coordinate.latitude,
                    "destinationLongitude": response.mapItems[0].placemark.coordinate.longitude,
                    "distance": distance
                ]
                docRef.setData(data) { error in
                    if let error = error {
                        print("Error saving location data: \(error.localizedDescription)")
                    } else {
                        print("Location data saved successfully")
                    }
                }
                
                // Show the route between the user's location and the destination location
                let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil)
                let destinationPlacemark = MKPlacemark(coordinate: response.mapItems[0].placemark.coordinate, addressDictionary: nil)
                
                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceMapItem
                directionRequest.destination = destinationMapItem
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let response = response else { return }
                    
                    let route = response.routes[0]
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
            }
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: response.mapItems[0].placemark.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
}
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 3.0
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }

           
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
               guard let annotation = view.annotation else { return }

               let request = MKLocalSearch.Request()
               request.naturalLanguageQuery = annotation.title ?? ""

               let search = MKLocalSearch(request: request)
               search.start { (response, error) in
                   guard let response = response else { return }

                   let mapItem = response.mapItems[0]
                   let placemark = mapItem.placemark
                   let mapItemLocation = placemark.coordinate

                   let mapItemMark = MKPlacemark(coordinate: mapItemLocation, addressDictionary: nil)
                   let selectedMapItem = MKMapItem(placemark: mapItemMark)
                   selectedMapItem.name = placemark.name

                   let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                   selectedMapItem.openInMaps(launchOptions: options)
               }
           }
       
