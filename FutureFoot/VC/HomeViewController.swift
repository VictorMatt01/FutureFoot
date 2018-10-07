//
//  HomeViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 18/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var trainingCollectionView: UICollectionView!
    @IBOutlet weak var trainingTableView: UITableView!
    
    var dataController:DataController!
    let imagePicker = UIImagePickerController()
    var trainingImages: [TrainingImage] = []
    var trainingDates: [TrainingDate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainingCollectionView.delegate = self
        trainingCollectionView.dataSource = self
        trainingTableView.delegate = self
        trainingTableView.dataSource = self
        imagePicker.delegate = self
        loadTrainingImages()
        loadTrainingDates()
    }
    
    func loadTrainingImages(){
        let fetchRequest:NSFetchRequest<TrainingImage> = TrainingImage.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            trainingImages = result
            trainingCollectionView.reloadData()
        }
    }
    
    func loadTrainingDates(){
        let fetchRequest2:NSFetchRequest<TrainingDate> = TrainingDate.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest2.sortDescriptors = [sortDescriptor]
        do {
            trainingDates = try dataController.viewContext.fetch(fetchRequest2)
            trainingTableView.reloadData()
        } catch {
            showAlert(message: "Fetching Failed")
        }
    }
    
    @IBAction func AddTrainingTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addTrainingDateTapped(_ sender: Any) {
        let addTrainingDataAlertView = UIAlertController(title: "Add TrainingDate", message: "Give the date, place and title of the training", preferredStyle: .alert)
        
        addTrainingDataAlertView.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let dateTextField = addTrainingDataAlertView.textFields![0] as UITextField
            let placeTextField = addTrainingDataAlertView.textFields![1] as UITextField
            let titleTextField = addTrainingDataAlertView.textFields![2] as UITextField
            
            if dateTextField.text != "" && placeTextField.text != "" && titleTextField.text != ""{
                //if all textfields are used then save the new trainingdate to codedata and save in the array of trainingdates
                let newTrainingDate = TrainingDate(context: self.dataController.viewContext)
                newTrainingDate.day = dateTextField.text!
                newTrainingDate.place = placeTextField.text!
                newTrainingDate.title = titleTextField.text!
                try? self.dataController.viewContext.save()
                self.trainingDates.append(newTrainingDate)
                self.trainingTableView.reloadData()
            }else{
                let alertTextFieldsError = UIAlertController(title: "Error", message: "Could not save the training, one of your textfields was empy!", preferredStyle: .alert)
                alertTextFieldsError.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                    
                }))
                DispatchQueue.main.async {
                    self.present(alertTextFieldsError, animated: true, completion: nil)
                }
            }
        }))
        
        addTrainingDataAlertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            //we don't need to save the new trainingdate
        }))
        
        addTrainingDataAlertView.addTextField { (textfield) in
            textfield.placeholder = "Date"
            textfield.textAlignment = .center
        }
        
        addTrainingDataAlertView.addTextField { (textfield) in
            textfield.placeholder = "Place"
            textfield.textAlignment = .center
        }
        
        addTrainingDataAlertView.addTextField { (textfield) in
            textfield.placeholder = "Title"
            textfield.textAlignment = .center
        }
        
        self.present(addTrainingDataAlertView, animated: true, completion: nil)
    }
    
    //MARK: -UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // we save the choosen image to the coredata
            let newTrainingImage = TrainingImage(context: dataController.viewContext)
            newTrainingImage.image = UIImagePNGRepresentation(pickedImage)
            //we set the date as the name of the picture
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM HH:mm"
            let result = formatter.string(from: date)
            newTrainingImage.name = result
            try? dataController.viewContext.save()
            trainingImages.append(newTrainingImage)
            trainingCollectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -TrainingCollectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrainingPicture", for: indexPath) as! TrainingImageCollectionViewCell
        let trainingImageData = trainingImages[indexPath.item]
        cell.trainingImageView.image = UIImage(data: trainingImageData.image!)
        cell.trainingImageName.text = trainingImageData.name
        return cell
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //reuseIdentifier = trainingDateCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainingDateCell")!
        let cellTrainingDate = trainingDates[indexPath.row]
        let cellString = cellTrainingDate.title! + " - " + cellTrainingDate.place! + " - " + cellTrainingDate.day!
        cell.textLabel?.text = cellString
        return cell
    }
    
    
}
