//
//  SignUpViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 16/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    var ref: DatabaseReference!
    var helpTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        birthdayPicker.datePickerMode = .date
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            showAlert(message: "firstName textfield is nil or empty.")
            return
        }
        guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            showAlert(message: "lastname textfield is nil or empty.")
            return
        }
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "email textfield is nil or empty.")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "password textfield is nil or empty.")
            return
        }
        
        birthdayPicker.datePickerMode = UIDatePickerMode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let selectedDate = birthdayPicker.date
        
        //create user in firebase auth
        Auth.auth().createUser(withEmail: "\(email)", password: "\(password)") { (user, error) in
            if error == nil {
                let currentUser = Auth.auth().currentUser
                let changeRequest = currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = "\(firstName) \(lastName) \(selectedDate)"
                changeRequest?.commitChanges { error in
                    if let error = error {
                        self.showAlert(message: "Could not made profile correctly! with error:\(error)")
                    } else {
                        let object = UIApplication.shared.delegate as! AppDelegate
                        object.currentUser = currentUser
                    }
                }
                let curretnUserUID = currentUser?.uid as! String
                //we also add the subclass teams, players and Coaches to the database
                self.ref.child("\(curretnUserUID)").child("Teams").setValue("test")
                self.ref.child("\(curretnUserUID)").child("Players").setValue("testest")
                
                //send verivication mail
                currentUser!.sendEmailVerification(completion: { (error) in
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Alert", message: "A verification link has been send to your email account", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style{
                            case .default:
                                //show login screen
                                let loginScreen = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                                self.present(loginScreen, animated: true, completion: nil)
                            case .cancel:
                                print("cancel")
                            case .destructive:
                                print("destructive")
                            }}))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }else {
                DispatchQueue.main.async {
                    self.showAlert(message: "\(String(describing: error?.localizedDescription))")
                }
            }
        }
        
    }
    
    //MARK: -TextFieldDelegate
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        helpTextField = textField
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        if keyboardSize.cgRectValue.origin.y < (helpTextField.frame.origin.y + helpTextField.frame.size.height) {
            //keyboard covers textfield so we move it up!
            let heigthToMoveUp = (helpTextField.frame.origin.y + helpTextField.frame.size.height) - keyboardSize.cgRectValue.size.height
            view.frame.origin.y -= heigthToMoveUp
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
