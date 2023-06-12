//
//  DriverHome.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 3/15/23.
//

import UIKit
import SideMenu
import Firebase
class DriverHome: UIViewController {
    private let sidemenu = SideMenuNavigationController(rootViewController:Menucontroller(with: ["Home", "Support", "Settings", "Logout"]) )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidemenu.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sidemenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        navigationItem.hidesBackButton = true
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func Logoutap(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            // If sign out is successful, navigate back to the root view controller
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func tapmenu(_ sender: UIBarButtonItem) {
        present(sidemenu, animated: true)
        
    }
    
    @IBAction func driveNow(_ sender: UIButton) {
        
    }
    
    @IBAction func schedule(_ sender: UIButton) {
    }
}
class Menucontroller: UITableViewController{
    
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
                // Handle selection for "Home"
                break
            case 1:
                // Handle selection for "Support"
                break
            case 2:
                // Handle selection for "Logout"
            
            do {
              try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
            case 3:
                // Handle selection for "Settings"
                break
            default:
                break
            }
    }
}
        
