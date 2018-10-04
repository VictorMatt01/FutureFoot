//
//  TeamsViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 17/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseDatabase

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var teamTableView: UITableView!
    
    var ref: DatabaseReference!
    var teams:[Team] = []
    let object = UIApplication.shared.delegate as! AppDelegate
    
    let spinner = UIActivityIndicatorView()
    let loadingView = UIView()
    let loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTeamTapped))
        teamTableView.delegate = self
        teamTableView.dataSource = self
        setLoadingScreen()
        loadTeams()
    }
    
    //MARK: -loading
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (teamTableView.frame.width / 2) - (width / 2)
        let y = (teamTableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        teamTableView.addSubview(loadingView)
    }
    
    private func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
        
    }
    
    
    func loadTeams(){
        let teams = ref.child("\(object.currentUser.uid )").child("Teams")
        teams.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for (_, result) in value {
                    let initDic = result as! NSDictionary
                    let newTeam = Team(initDic: initDic)
                    self.teams.append(newTeam)
                }
            }
            self.teamTableView.reloadData()
            self.removeLoadingScreen()
        }
    }
    
    //MARK: -AddTeam
    //add a new Team to the database and tableview
    @objc func addTeamTapped(){
        //show alert window with textfield for teamName
        let addTeamAlertView = UIAlertController(title: "Add Team", message: "Type the name of your team and coach", preferredStyle: .alert)
        
        addTeamAlertView.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let teamNameTextField = addTeamAlertView.textFields![0] as UITextField
            let coachNameTextField = addTeamAlertView.textFields![1] as UITextField
            
            if teamNameTextField.text != "" {
                //add team to database and reloadData
                self.ref.child("\(self.object.currentUser.uid )").child("Teams").child("\(teamNameTextField.text!)").child("teamName").setValue("\(teamNameTextField.text!)")
                self.ref.child("\(self.object.currentUser.uid )").child("Teams").child("\(teamNameTextField.text!)").child("coachName").setValue("\(coachNameTextField.text!)")
                //make new object of team
                //first we make an initDic
                let initDic:NSDictionary = ["teamName" : teamNameTextField.text!, "countPlayers":"0", "coachName" : coachNameTextField.text!]
                let newTeam = Team(initDic: initDic)
                self.teams.append(newTeam)
            }
            self.teamTableView.reloadData()
        }))
        
        addTeamAlertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            //cancel button clicked, so we don't need to add a new team to the database
        }))
        
        addTeamAlertView.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Team name"
            textField.textAlignment = .center
        })
        addTeamAlertView.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Coach name"
            textField.textAlignment = .center
        })
        self.present(addTeamAlertView, animated: true, completion: nil)
    }
    
    // MARK: -Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playerCell = tableView.dequeueReusableCell(withIdentifier: "teamCell")
        playerCell?.textLabel?.text = teams[indexPath.row].teamName
        return playerCell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //get teamName
            let teamNameToDelete = self.teams[indexPath.row].teamName
            //delete from database
            ref.child("\(object.currentUser.uid )").child("Teams").child("\(teamNameToDelete as! String)").removeValue()
            //delete from teamsArray
            self.teams.remove(at: indexPath.row)
            //delete from tableview
            teamTableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specificTeamVC = self.storyboard?.instantiateViewController(withIdentifier: "specificTeam") as! SpecificTeamViewController
        specificTeamVC.specificTeam = teams[indexPath.row]
        self.navigationController?.pushViewController(specificTeamVC, animated: true)
    }
    
}

