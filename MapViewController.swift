//
//  MapViewController.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 3/25/23.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class MapViewController: UIViewController,  MKMapViewDelegate {
    var startLocation: String?
    var endLocation: String?
    var directions: MKDirections?
    var distance: CLLocationDistance = 0
    var price: Double = 0
    var estimatedTime: TimeInterval = 0
    
    
    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        // Enable showing user's location on the map view
        mapview.showsUserLocation = true
        
        
        // Call the method to get the directions and display them on the map view
        getDirections()
    }
    
    // Implement the MKMapViewDelegate method to display the route on the map view
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 10.0
        return renderer
    }
    
    @IBAction func bookNow(_ sender: UIButton) {
    }
    func getDirections() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(startLocation ?? "") { [weak self] (startPlacemarks, error) in
            guard let self = self, let startPlacemark = startPlacemarks?.first, error == nil else { return }
            
            let startCoordinate = startPlacemark.location?.coordinate ?? CLLocationCoordinate2D()
            let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate, addressDictionary: nil))
            startMapItem.name = self.startLocation
            
            geocoder.geocodeAddressString(self.endLocation ?? "") { (endPlacemarks, error) in
                guard let endPlacemark = endPlacemarks?.first, error == nil else { return }
                
                let endCoordinate = endPlacemark.location?.coordinate ?? CLLocationCoordinate2D()
                let endMapItem = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate, addressDictionary: nil))
                endMapItem.name = self.endLocation
                
                let request = MKDirections.Request()
                request.source = startMapItem
                request.destination = endMapItem
                request.transportType = .automobile
                
                self.directions = MKDirections(request: request)
                self.directions?.calculate(completionHandler: { [weak self] (response, error) in
                    guard let self = self, let response = response, error == nil else { return }
                    
                    // Calculate the distance and price
                    let distance = response.routes[0].distance

                    let baseFare = 2.0 // Change the base fare as needed
                    let distanceRate = 0.5 // Change the rate per mile as needed
                    let timeRate = 0.1 // Change the rate per minute as needed

                    let estimatedTime = response.routes[0].expectedTravelTime
                    let timeInMinutes = estimatedTime / 60

                    var price: Double = 0
                    if distance < 2 { // if the distance is less than 2 miles, set a fixed price of $10
                        price = 10.0
                    } else {
                        let distanceInMiles = distance/1609.34 // convert distance from meters to miles
                        let distanceFare = distanceInMiles * distanceRate
                        let timeFare = timeInMinutes * timeRate
                        price = baseFare + distanceFare + timeFare
                    }

                    // Update the price and estimated time labels
                    self.priceLabel.text = String(format: "$%.2f", price)
                    self.timeLabel.text = String(format: "%.1f min", estimatedTime/60)

                    // Save the trip details to Firestore
                    let db = Firestore.firestore()
                    db.collection("trips").addDocument(data: [
                        "start_location": self.startLocation ?? "",
                        "end_location": self.endLocation ?? "",
                        "distance": distance,
                        "price": price,
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added")
                        }
                    }
                    
                    for route in response.routes {
                        for step in route.steps {
                            // Add start and end annotations for each step
                            let startAnnotation = MKPointAnnotation()
                            startAnnotation.coordinate = step.polyline.points()[0].coordinate
                            startAnnotation.title = step.instructions
                            self.mapview.addAnnotation(startAnnotation)
                            
                            let endAnnotation = MKPointAnnotation()
                            endAnnotation.coordinate = step.polyline.points()[1].coordinate
                            endAnnotation.title = step.notice
                            self.mapview.addAnnotation(endAnnotation)
                            
                            // Add polyline for each step
                            let polyline = step.polyline
                            self.mapview.addOverlay(polyline, level: .aboveRoads)
                        }
                    }
                    
                    let region = response.routes[0].polyline.boundingMapRect
                    self.mapview.setRegion(MKCoordinateRegion(region), animated: true)
                })
            }
        }
    }
}
