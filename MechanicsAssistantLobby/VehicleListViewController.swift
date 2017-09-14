//
//  ViewController.swift
//  MechanicsAssistantLobby
//
//  Created by Beau Burchfield on 8/16/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase

open class CustomVehicleCell:  UITableViewCell {
    
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var completionImage: UIImageView!
    @IBOutlet weak var completionLabel: UILabel!
    
}

//public variable for the ID of vehicle selected
public var currentID = ""

class VehicleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //variable for a collection of data from Firebase
    var tempVehicles = [DataSnapshot]()
    var vehicles = [DataSnapshot]()
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Link table view cells with custom cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.0)
        self.tableView.register(UINib(nibName: "CustomVehicleCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //load business logo and background color
        //Decode logo image from base64 string
        let dataDecoded : Data = Data(base64Encoded: currentBusinessLogo, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        logoView.image = decodedimage
        
        if currentBusinessColor == "0" {
            backgroundImage.image = UIImage(named: "BackgroundBlue")
        } else if currentBusinessColor == "1" {
            backgroundImage.image = UIImage(named: "BackgroundRed")
        } else if currentBusinessColor == "2" {
            backgroundImage.image = UIImage(named: "BackgroundGreen")
        } else if currentBusinessColor == "3" {
            backgroundImage.image = UIImage(named: "BackgroundYellow")
        } else if currentBusinessColor == "4" {
            backgroundImage.image = UIImage(named: "BackgroundCyan")
        } else if currentBusinessColor == "5" {
            backgroundImage.image = UIImage(named: "BackgroundWhite")
        } else {
            backgroundImage.image = UIImage(named: "BackgroundBlue")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Setup Firebase reference variables
        let ref = Database.database().reference(withPath: "vehicles")
        // Listen for vehicles added to the Firebase database
        ref.observe(.value, with: { (snapshot) -> Void in
            self.tempVehicles = []
            self.vehicles = []
            
            //add vehicles to tempVehicles variable
            for item in snapshot.children {
                self.tempVehicles.append(item as! DataSnapshot)
            }
            
            self.delayWithSeconds(1) {
                for item in self.tempVehicles {
                    let value = item.value as? NSDictionary
                    let business = value?["business"] as? String ?? ""
                    let location = value?["location"] as? String ?? ""
                    if business == currentBusinessID && location == currentBusinessLocation {
                        self.vehicles.append(item)
                    }
                }
            }
            
            //After 2 seconds, reload table view data
            self.delayWithSeconds(2) {
                self.tableView.reloadData()
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Setup Firebase reference variables
        let ref = Database.database().reference(withPath: "vehicles")
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->  UITableViewCell{
        
        //create variable to track number of completed tasks
        var completionNumber = 0
        
        //create variable to track number of total statuses
        var statusNumber = 0
        
        //set custom cell to table view
        let cell: CustomVehicleCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomVehicleCell
        
        //set each cell to contain value of corresponding vehicles item; populate labels with data
        let value = vehicles[indexPath.row].value as? NSDictionary
        cell.makeLabel.text = value?["make"] as? String ?? ""
        cell.modelLabel.text = value?["model"] as? String ?? ""
        cell.customerLabel.text = value?["firstName"] as? String ?? ""
        cell.colorLabel.text = value?["color"] as? String ?? ""
        
        //get statuses and check their values. For each value completed, add 1 to completionNumber variable
        let completionStatuses = value?["statuses"] as? NSDictionary
        for (_, value) in completionStatuses! {
            
            //add 1 to total statuses
            statusNumber += 1
            
            //if value for status is yes, add one to total completed
            if value as? String == "yes" {
                completionNumber += 1
            }
        }
        
        //create completionPercent value, which is the percentage of completed items
        let completionPercent = (100 * completionNumber) / statusNumber
        
        //show correct completion image
        if completionPercent < 10 {
            cell.completionImage.image = UIImage(named: "CompletionWheel0")
        } else if completionPercent >= 10 && completionPercent < 20 {
            cell.completionImage.image = UIImage(named: "CompletionWheel10")
        } else if completionPercent >= 20 && completionPercent < 30 {
            cell.completionImage.image = UIImage(named: "CompletionWheel20")
        } else if completionPercent >= 30 && completionPercent < 40 {
            cell.completionImage.image = UIImage(named: "CompletionWheel30")
        } else if completionPercent >= 40 && completionPercent < 50 {
            cell.completionImage.image = UIImage(named: "CompletionWheel40")
        } else if completionPercent >= 50 && completionPercent < 60 {
            cell.completionImage.image = UIImage(named: "CompletionWheel50")
        } else if completionPercent >= 60 && completionPercent < 70 {
            cell.completionImage.image = UIImage(named: "CompletionWheel60")
        } else if completionPercent >= 70 && completionPercent < 80 {
            cell.completionImage.image = UIImage(named: "CompletionWheel70")
        } else if completionPercent >= 80 && completionPercent < 90 {
            cell.completionImage.image = UIImage(named: "CompletionWheel80")
        } else if completionPercent >= 90 && completionPercent < 100 {
            cell.completionImage.image = UIImage(named: "CompletionWheel90")
        } else {
            cell.completionImage.image = UIImage(named: "CompletionWheel100")
        }
        
        //display completion percentage
        cell.completionLabel.text = "\(completionPercent)% complete"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _: UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        //segue to checklist view controller
        performSegue(withIdentifier: "showChecklistSegue", sender: indexPath.row)
        
        //set currentID to selected vehicle's ID
        currentID = vehicles[indexPath.row].key
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
}
