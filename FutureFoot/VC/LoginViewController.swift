//
//  ViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 16/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var dataController:DataController!
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "firstName textfield is nil or empty.")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "firstName textfield is nil or empty.")
            return
        }
        
        Auth.auth().signIn(withEmail: "\(email)", password: "\(password)") { (user, error) in
            if error == nil {
                let homeTabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "homeTabBar") as! UITabBarController
                let homeVC = homeTabBarVC.viewControllers?.first as! HomeViewController
                homeVC.dataController = self.dataController
                let accountVC = homeTabBarVC.viewControllers![2] as! AccountViewController
                accountVC.dataController = self.dataController
                //set currentUser
                let currentUser = Auth.auth().currentUser
                let object = UIApplication.shared.delegate as! AppDelegate
                object.currentUser = currentUser
                self.present(homeTabBarVC, animated: true, completion: nil)
            }else {
                DispatchQueue.main.async {
                    self.showAlert(message: "\(String(describing: error?.localizedDescription))")
                }
            }
        }
        
        
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "signUpWindow") as! SignUpViewController
        self.navigationController?.pushViewController(signUpVC, animated: true)
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
    
    @objc func keyboardWillShow(_ notification:Notification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                print("ok")
            }
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: -AlertView
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
