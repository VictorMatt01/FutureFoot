//
//  AddPlayerViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 18/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddPlayerViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    var teamOfPlayer:Team!
    var ref: DatabaseReference!
    let object = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            showAlert(message: "firstName textfield is nil or empty.")
            return
        }
        guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            showAlert(message: "firstName textfield is nil or empty.")
            return
        }
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "firstName textfield is nil or empty.")
            return
        }
        birthdayPicker.datePickerMode = UIDatePickerMode.date
        let selectedDate = birthdayPicker.date
        
        //save the new player to the database
        let playerInfo = [
            "firstName":  "\(firstName)",
            "lastName": "\(lastName)",
            "email":   "\(email)",
            "birthday": "\(selectedDate.toString(dateFormat: "dd-MMM-yyyy"))"
        ]
        ref.child("\(object.currentUser.uid)").child("Players").child("PlayersOf: \(teamOfPlayer.teamName!)").child("\(firstName) \(lastName)").setValue(playerInfo)
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(message:String){
        let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
