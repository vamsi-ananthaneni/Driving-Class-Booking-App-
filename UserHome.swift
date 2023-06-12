//
//  UserHome.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 3/15/23.
//

import UIKit
import SideMenu
import Firebase
import CoreLocation
import MapKit

class UserHome: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKLocalSearchCompleterDelegate{
    
    private let sidemenu = SideMenuNavigationController(rootViewController:MenuController(with: ["user profile", "Support",  "Settings"]) )
    
    
    
    @IBOutlet weak var currentLocationTextField: UITextField!
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    
    let locationManager = CLLocationManager()
    let completer = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var lastRequestTime: TimeInterval = 0
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sidemenu.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sidemenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        // Hide the back button
        navigationItem.hidesBackButton = true
        locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
              currentLocationTextField.delegate = self
              destinationTextField.delegate = self
              
              completer.delegate = self
              completer.region = MKCoordinateRegion(MKMapRect.world)
              setRegionForSearch()
    }
    // Method for setting the region for the completer to search within
    func setRegionForSearch() {
        let centerCoordinate = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let searchRegion = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        completer.region = searchRegion
    }

    // CLLocationManagerDelegate method called when location updates are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            DispatchQueue.main.async {
                self.currentLocationTextField.text = placemark.name
            }
        }
    }

    // CLLocationManagerDelegate method called when location authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle authorization status changes here
    }
   
    // Handle item selection here
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func Logout(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            // If sign out is successful, navigate back to the root view controller
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func basicTap(_ sender: UIButton) {
       
    }
    
    @IBAction func expertTap(_ sender: UIButton) {
    }
    
    @IBAction func rideTap(_ sender: UIButton) {
        if let startLocation = currentLocationTextField.text,
                    let endLocation = destinationTextField.text,
                    !startLocation.isEmpty, !endLocation.isEmpty {
                     
                     // Use a geocoder to get the start and end coordinates
                     let geocoder = CLGeocoder()
                     geocoder.geocodeAddressString(startLocation) { startPlacemarks, startError in
                         guard let _ = startPlacemarks?.first?.location, startError == nil else {
                             let alert = UIAlertController(title: "Error", message: "Invalid start location", preferredStyle: .alert)
                             alert.addAction(UIAlertAction(title: "OK", style: .default))
                             self.present(alert, animated: true)
                             return
                         }
                         
                         geocoder.geocodeAddressString(endLocation) { endPlacemarks, endError in
                             guard let _ = endPlacemarks?.first?.location, endError == nil else {
                                 let alert = UIAlertController(title: "Error", message: "Invalid end location", preferredStyle: .alert)
                                 alert.addAction(UIAlertAction(title: "OK", style: .default))
                                 self.present(alert, animated: true)
                                 return
                             }
                             
                             self.performSegue(withIdentifier: "MapViewSegue", sender: self)
                         }
                     }
                     
                 } else {
                     // show an alert to prompt the user to fill in both location fields
                     let alert = UIAlertController(title: "Error", message: "Please fill in both start and end locations.", preferredStyle: .alert)
                     let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                     alert.addAction(okAction)
                     self.present(alert, animated: true, completion: nil)
                 }
            }

            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "MapViewSegue", let mapVC = segue.destination as? MapViewController {
                    // Set properties or variables on mapVC here
                    mapVC.startLocation = currentLocationTextField.text
                    mapVC.endLocation = destinationTextField.text
                }
            }

    
    
    @IBAction func menutap(_ sender: UIBarButtonItem) {
        present(sidemenu, animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentLocationTextField.endEditing(true)
        destinationTextField.endEditing(true)
        return true
        
    }
   
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            searchResults = completer.results
            // Handle search results here
        }
    }
    
    
    class MenuController: UITableViewController{
        
        private let menuitems: [String]
        init(with menuitems: [String]) {
            self.menuitems = menuitems
            super.init(nibName: nil, bundle: nil)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func viewDidLayoutSubviews() {
            super.viewDidLoad()
        }
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return menuitems.count
        }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = menuitems[indexPath.row]
            return cell
            
        }
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            switch indexPath.row {
            case 0:
                // Handle selection for "userprofile"
                break
            case 1:
                // Handle selection for "Support"
                break
            case 2:
                // Handle selection for "settings
                
                break
                
            default:
                break
            }
        }
    }
    
    
    
    
    

