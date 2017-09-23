//
//  EnterBusinessViewController.swift
//  MechanicsAssistantLobby
//
//  Created by Beau Burchfield on 9/12/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

var currentBusinessID = ""
var currentBusinessLocation = ""
var currentBusinessEmail = ""
var currentBusinessColor = ""
var currentBusinessName = ""
var currentBusinessLogo = ""

class EnterBusinessViewController: UIViewController {
    
    var businesses = [DataSnapshot]()
    
    @IBOutlet weak var businessIDField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicator.isHidden = true
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let ref = Database.database().reference(withPath: "businesses")
        ref.removeAllObservers()
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        
        //If errors, handle them
        if businessIDField.text == "" || locationField.text == "" {
            
            if businessIDField.text == "" {
                showTextFieldPlaceholder(textfield: businessIDField, placeholderString: "Enter a business ID")
            }
            
            if locationField.text == "" {
                showTextFieldPlaceholder(textfield: locationField, placeholderString: "Enter a location")
            }
            
        } else {
            
            
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            self.businesses = []
            
            //Setup Firebase reference variables
            let ref = Database.database().reference(withPath: "businesses")
            // Listen for vehicles added to the Firebase database
            ref.observe(.value, with: { (snapshot) -> Void in
                
                self.businesses = []
                var shouldShowAlert = true
                //add vehicles to vehicles variable
                for item in snapshot.children{
                    self.businesses.append(item as! DataSnapshot)
                }
                
                self.delayWithSeconds(1){
                    var itemNumber = 0
                    for item in self.businesses {
                        
                        let value = item.value as? NSDictionary
                        let id = value?["id"] as? String ?? ""
                        if id == self.businessIDField.text {
                            currentBusinessID = self.businessIDField.text!
                            currentBusinessLocation = self.locationField.text!
                            currentBusinessName = value?["name"] as? String ?? ""
                            currentBusinessColor = value?["color"] as? String ?? ""
                            currentBusinessEmail = value?["email"] as? String ?? ""
                            currentBusinessLogo = value?["logo"] as? String ?? ""
                            shouldShowAlert = false
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.performSegue(withIdentifier: "SuccessfulSignIn", sender: self)
                            return
                        } else {
                            
                            itemNumber += 1
                            
                        }
                        
                    }
                    
                    if shouldShowAlert == true {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.displayAlert("No Business Found", alertString: "There is no business information associated with this data.")
                    }
                    
                }
                
            })
            
        }
        
    }
    
    //function to display errors at text fields
    func showTextFieldPlaceholder(textfield: UITextField, placeholderString: String){
        
        textfield.text = ""
        
        //create shake animation
        let shake = CAKeyframeAnimation( keyPath:"transform" )
        shake.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        if textfield.text == "" {
            textfield.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSForegroundColorAttributeName: UIColor.red])
            textfield.layer.add(shake, forKey: nil)
        }
        
        
    }
    
    //function for displaying an alert controller
    func displayAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Function to check connection availability
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
}
