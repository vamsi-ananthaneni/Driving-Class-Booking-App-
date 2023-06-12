//
//  PaymentViewController.swift
//  L Drive
//
//  Created by Dharma Teja Donepudi on 4/4/23.
//

import UIKit
import Stripe
import PassKit
import AWSLambda

class PaymentViewController: UIViewController, UITextFieldDelegate, PKPaymentAuthorizationViewControllerDelegate, UINavigationControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    
    @IBOutlet weak var expDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    var price: Double = 0.0 // Assuming the type of price is Double
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceLabel.text = "Price: $\(price)"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set up the Stripe API key
        StripeAPI.defaultPublishableKey = "pk_test_51MtKm9KAk6lyq9PYc5Vi3HSnw8ShCpO8qoQNaMC8leybF5uvDzxX0nT8nb2b3D0gf5mpuwcwH5K9kDIc7MdKtXeT00j6td561n"
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        // Handle Confirm button tapped
        
        // Validate card details
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty,
              let expDate = expDateTextField.text, !expDate.isEmpty,
              let cvv = cvvTextField.text, !cvv.isEmpty else {
            // Show an alert for invalid card details
            showAlert(title: "Error", message: "Please enter valid card details.")
            return
        }
        
        // Extract expiration month and year from the combined expDate
        let expMonthString = expDate.prefix(2)
        let expYearString = expDate.suffix(2)
        
        // Create STPCardParams object
        let cardParams = STPCardParams()
        cardParams.number = cardNumber
        cardParams.expMonth = UInt(expMonthString)!
        cardParams.expYear = UInt(expYearString)!
        cardParams.cvc = cvv
        // Validate card params
        let validationState = STPCardValidator.validationState(forCard: cardParams)
        if validationState != .valid {
            // Show an alert for invalid card details
            showAlert(title: "Error", message: "Please enter valid card details.")
            return
        }
        
        // Create a PaymentMethodParams object with the collected card details
        let paymentMethodParams = STPPaymentMethodParams()
        paymentMethodParams.type = .card
        paymentMethodParams.card = STPPaymentMethodCardParams()
        paymentMethodParams.card?.number = cardParams.number
        paymentMethodParams.card?.expMonth = ((cardParams.expMonth) as NSNumber)
        paymentMethodParams.card?.expYear = ((cardParams.expYear) as NSNumber)
        paymentMethodParams.card?.cvc = cardParams.cvc
        
        STPAPIClient.shared.createPaymentMethod(with: paymentMethodParams) { (paymentMethod, error) in
            if let error = error {
                // Handle payment method creation failure
                print("Error creating payment method: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to create payment method. Please try again.")
            } else if let paymentMethod = paymentMethod {
                // Payment method creation successful
                self.processPayment(paymentMethod: paymentMethod)
            }
        }
    }
    
    @IBAction func applePayButtonTapped(_ sender: UIButton) {
        // Handle Apple Pay button tapped
        // Convert the price to cents (Stripe uses cents as the unit for currency)
        let _ = Int(price * 100)
        
        // Create a PaymentRequest for Apple Pay
        let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: "merchant.CO.DHARMA.Learn-L-Drive.L-Drive", country: "US", currency: "USD")
        
        // Configure the PaymentRequest with the required information
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Your Item", amount: NSDecimalNumber(value: price))]
        
        // Create a PaymentAuthorizationViewController with the PaymentRequest
        let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        paymentAuthorizationViewController?.delegate = self
        
        // Present the PaymentAuthorizationViewController
        if let paymentAuthorizationViewController = paymentAuthorizationViewController {
            self.present(paymentAuthorizationViewController, animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func processPayment(paymentMethod: STPPaymentMethod) {
        // Here, you can further process the payment using the `paymentMethod` object, for example:
        
        // Get the payment method ID
        let _ = paymentMethod.stripeId
        
        // Get the payment method type (e.g., card, bank account, etc.)
        let _ = paymentMethod.type.rawValue
        
        // Get the payment method details, such as card brand, last 4 digits, etc.
        if let cardDetails = paymentMethod.card {
            let _ = cardDetails.brand.rawValue
            let _ = cardDetails.last4
            // Use the payment method details to complete the payment processing
            
            
            


        }
        
        
       

        
    }
    
    
}
