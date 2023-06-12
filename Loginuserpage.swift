//
//  Loginuserpage.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 2/27/23.
//

import UIKit
import Firebase

class Loginuserpage: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailTextfield.delegate = self
        passwordTextf.delegate = self
    }
    
    
    @IBAction func loginClicked(_ sender: UIButton) {
        emailTextfield.endEditing(true)
        passwordTextf.endEditing(true)
        
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextf.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let e = error {
                if error == nil {
                        // Login successful
                        let alertController = UIAlertController(title: "Login Successful", message: "You have successfully logged in.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        // Login failed
                        let alertController = UIAlertController(title: "Login Failed", message: error?.localizedDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                print(e)
            }
            else {
                self.performSegue(withIdentifier: "gotouser", sender: self)
                
            }
            
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextfield.endEditing(true)
        passwordTextf.endEditing(true)
        return true
        
    }
    
}
