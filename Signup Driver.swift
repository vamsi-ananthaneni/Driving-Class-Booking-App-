//
//  Signup Driver.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 3/6/23.
//

import UIKit
import Firebase

class Signup_Driver: UIViewController , UITextFieldDelegate {
    var db: Firestore = Firestore.firestore()
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    
    
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var phonenumberText: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var confirmpasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextfield.delegate = self
        emailTextfield.delegate = self
        phonenumberText.delegate = self
        passwordTextfield.delegate = self
        confirmpasswordText.delegate = self
    }
    
    
    @IBAction func singupClick(_ sender: UIButton) {
        emailTextfield.endEditing(true)
                usernameTextfield.endEditing(true)
                passwordTextfield.endEditing(true)
                confirmpasswordText.endEditing(true)
                phonenumberText.endEditing(true)
                guard let email = emailTextfield.text,
                      let password = passwordTextfield.text,
                      let confirmpassword = confirmpasswordText.text,
                      let username = usernameTextfield.text,
                      let phoneNumber = phonenumberText.text,
                      !email.isEmpty,
                      !password.isEmpty,
                      !phoneNumber.isEmpty,
                      !username.isEmpty,
                      password == confirmpassword
                else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] firebaseResult, error in
                    guard let self = self else { return }
                    
                    if let e = error {
                        print(e)
                        let alert = UIAlertController(title: "Error", message: "Invalid email or password", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.commitChanges(completion: nil)
                        
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                            if let e = error {
                                print(e)
                                let alert = UIAlertController(title: "Error", message: "Could not send verification email", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                let alert = UIAlertController(title: "Success", message: "You have successfully signed up. Please check your email and click the verification link to activate your account.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                                // Store user information in Firestore
                                if let uid = Auth.auth().currentUser?.uid {
                                    self.db.collection("driver").document(uid).setData([
                                        "username": username,
                                        "email": email,
                                        "phoneNumber": phoneNumber
                                    ]) { error in
                                        if let error = error {
                                            print("Error writing document: \(error)")
                                        } else {
                                            print("Document successfully written!")
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            }
           func textFieldShouldReturn(_ textField: UITextField) -> Bool {
               emailTextfield.endEditing(true)
               usernameTextfield.endEditing(true)
               passwordTextfield.endEditing(true)
               confirmpasswordText.endEditing(true)
               phonenumberText.endEditing(true)
               return true
           }
       }

