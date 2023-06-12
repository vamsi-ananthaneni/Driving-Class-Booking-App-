//
//  ForgotpasswordUser.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 3/7/23.
//

import UIKit
import Firebase
class ForgotpasswordUser: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextf.delegate = self
    }
    
    
    
    @IBAction func forgotClick(_ sender: UIButton) {
        emailTextf.endEditing(true)
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: emailTextf.text!) { (error ) in
            if error != nil {
                if let error = error {
                       // If there was an error sending the reset password email, display an error message to the user
                       let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(alert, animated: true, completion: nil)
                } else {
                    // If the reset password email was sent successfully, display a message to the user
                    let alert = UIAlertController(title: "Password Reset Email Sent", message: "Please check your email to reset your password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    let alertController = UIAlertController(title: "Reset Password", message: "Would you like to reset your password?", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    let resetAction = UIAlertAction(title: "Reset", style: .default) { (_) in
                        // Perform the reset password action here
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(resetAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
        // MARK: - Navigation
        
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextf.endEditing(true)
        return true
    }
}
