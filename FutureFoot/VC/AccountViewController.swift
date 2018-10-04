//
//  AccountViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 18/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import CoreData

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var accountImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UILabel!
    @IBOutlet weak var secondNameTextField: UILabel!
    @IBOutlet weak var emailTextField: UILabel!
    @IBOutlet weak var birthdayTextField: UILabel!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    let imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    var firstName:String!
    var secondName:String!
    let object = UIApplication.shared.delegate as! AppDelegate
    var accImage:[UIImage]!
    var alreadyAnImage:Bool!
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageActivityIndicator.startAnimating()
        imagePicker.delegate = self
        setScreen()
    }
    
    @IBAction func EditImageTapped(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "choose an option", preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "photoLibrary", style: .default) { (alert) in
            self.pickImageFromLibrary()
        }
        optionMenu.addAction(photoLibraryAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: -functions
    func setScreen(){
        let currentUser = object.currentUser
        checkForProfilePicture()
        let fullNameArr = currentUser?.displayName?.components(separatedBy: " ")
        firstName = (fullNameArr?[0])!
        secondName = (fullNameArr?[1])!
        let email:String = (currentUser?.email)!
        let birhtday:String = (fullNameArr?[2])!
        firstNameTextField.text = "Firstname: \(firstName!)"
        secondNameTextField.text = "Lastname: \(secondName!)"
        birthdayTextField.text = "Birthday: \(birhtday)"
        emailTextField.text = "Email: \(email)"
    }
    
    func checkForProfilePicture(){
        //check if there is a accountImage in coredata if so set it in the imageView
        let fetchRequest:NSFetchRequest<AccountImage> = AccountImage.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let accImages = try dataController.viewContext.fetch(fetchRequest)
            if accImages.count == 0 {
                //no image selected
                imageActivityIndicator.stopAnimating()
                imageActivityIndicator.isHidden = true
                alreadyAnImage = false
                accountImage.image = UIImage(imageLiteralResourceName: "imageNotFound")
            }else if accImages.count == 1 {
                //get the image and set in imageview
                let accImageData = accImages[0].image
                imageActivityIndicator.stopAnimating()
                imageActivityIndicator.isHidden = true
                alreadyAnImage = true
                accountImage.image = UIImage(data: accImageData!)
            }
            
        } catch {
            showAlert(message: "Fetching Failed")
        }
    }
    
    func pickImageFromLibrary(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: -ImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let dataOfPickedImage = UIImagePNGRepresentation(pickedImage)
            //first check if there is already an accountImage
            if alreadyAnImage {
                
                //if so then update the picture in coredata
                let fetchRequest:NSFetchRequest<AccountImage> = AccountImage.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "image", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                do {
                    let accImages = try dataController.viewContext.fetch(fetchRequest)
                    accImages[0].setValue(dataOfPickedImage, forKey: "image")
                    try? self.dataController.viewContext.save()
                    accountImage.image = pickedImage
                } catch {
                    showAlert(message: "Fetching Failed")
                }
            }else{
                //else put the new picture in coredata
                accountImage.image = pickedImage
                //save the image that just has been picked
                let newAccountImage = AccountImage(context: dataController.viewContext)
                newAccountImage.image = dataOfPickedImage
                try? self.dataController.viewContext.save()
                alreadyAnImage = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: -logout
    @IBAction func logoutButtonTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -alertmessage
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
