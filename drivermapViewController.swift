//
//  drivermapViewController.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 4/13/23.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class drivermapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Request location authorization
            locationManager.requestWhenInUseAuthorization()
            
            // Set delegate
            locationManager.delegate = self
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // Start updating location
            locationManager.startUpdatingLocation()
            
            // Set map view to show user location
            mapView.showsUserLocation = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Update map view to show current location
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            
            // Update other parts of your app with the driver's current location as needed
            let driverLatitude = location.coordinate.latitude
            let driverLongitude = location.coordinate.longitude
            print("Driver Location: Latitude: \(driverLatitude), Longitude: \(driverLongitude)")
            // Check driver distance from user
                    if let userLocation = manager.location {
                        checkDriverDistance(from: userLocation)
                    }
        }
    }
    func saveDriverLocationToFirestore(latitude: Double, longitude: Double) {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User not logged in")
                return
            }

            let _ = GeoPoint(latitude: latitude, longitude: longitude)
            let driverLocationData = ["latitude": latitude, "longitude": longitude]

            // Update Firestore with the driver's current location
            db.collection("drivers").document(userId).setData(driverLocationData) { error in
                if let error = error {
                    print("Error saving driver location to Firestore: \(error.localizedDescription)")
                } else {
                    print("Driver location saved to Firestore")
                }
            }
        }
    
    func checkDriverDistance(from userLocation: CLLocation) {
        guard let driverLocation = locationManager.location else {
            print("Driver location not available")
            return
        }
        
        let distance = driverLocation.distance(from: userLocation)
        if distance <= 15 * 1609.34 { // Convert 15 miles to meters
            // Show the request view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let requestVC = storyboard.instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
            requestVC.distanceText = String(format: "%.1f", distance/1609.34) + " mi"
            
            // Retrieve the user's selected time from Firestore and set it as the timeText property of the RequestViewController
            let db = Firestore.firestore()
            let docRef = db.collection("timeSaved").document("documentId") // replace "documentId" with the ID of the document that contains the user's selected time
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let selectedTimeInMinutes = document.get("appointmentTime") as? Int ?? 0
                    let timeText = "\(selectedTimeInMinutes) mins"
                    requestVC.timeText = timeText
                } else {
                    print("Document does not exist")
                }
                
                // Present the RequestViewController to the user
                self.present(requestVC, animated: true, completion: nil)
            }
        }
    }

}
