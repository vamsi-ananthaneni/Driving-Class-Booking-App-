//
//  Driverlogin.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 2/27/23.
//

import UIKit
import Firebase


class Driverlogin: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        emailTextfield.textContentType = .username
          passwordTextfield.textContentType = .password
    }
    
    
    @IBAction func loginClicked(_ sender: UIButton) {
        emailTextfield.endEditing(true)
        passwordTextfield.endEditing(true)
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextfield.text else { return }
        
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
                self.performSegue(withIdentifier: "gotohome", sender: self)
                
            }
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextfield.endEditing(true)
        passwordTextfield.endEditing(true)
        
        return true
    }
    
}

