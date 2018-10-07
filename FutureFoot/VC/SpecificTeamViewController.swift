//
//  SpecificTeamViewController.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 18/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

class SpecificTeamViewController: UIViewController{
    
    @IBOutlet weak var specificTeamTableView: UITableView!
    
    var specificTeam:Team!
    var players:[Player] = []
    var ref: DatabaseReference!
    let object = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        specificTeamTableView.delegate = self
        specificTeamTableView.dataSource = self
        self.navigationItem.title = specificTeam.teamName
        let addPlayerBarButton = UIBarButtonItem(title: "Add Player", style: .plain, target: self, action: #selector(addPLayerTapped))
        self.navigationItem.rightBarButtonItems = [addPlayerBarButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlayers()
    }
    
    @objc func addPLayerTapped(){
        let addPLayerVC = self.storyboard?.instantiateViewController(withIdentifier: "addPlayer") as! AddPlayerViewController
        addPLayerVC.teamOfPlayer = specificTeam
        self.navigationController?.pushViewController(addPLayerVC, animated: true)
    }
    
    func loadPlayers(){
        players = []
        let specificTeamName:String = specificTeam.teamName
        //get all players from that team and put them in the players array
        let playersOfTeam = ref.child("\(object.currentUser.uid)").child("Players").child("PlayersOf: \(specificTeamName)")
        playersOfTeam.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for(_, result) in value {
                    let initDic = result as! NSDictionary
                    let newPlayer = Player(initDic: initDic)
                    self.players.append(newPlayer)
                }
            }
            self.specificTeamTableView.reloadData()
        }
    }
}

extension SpecificTeamViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playerCell = tableView.dequeueReusableCell(withIdentifier: "playerCell")
        let playerOfRow = players[indexPath.row]
        playerCell?.textLabel?.text = "\(playerOfRow.firstName as! String) \(playerOfRow.lastName as! String)"
        return playerCell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //get player to delete
            let playerNameToDelete = self.players[indexPath.row]
            ref.child("\(object.currentUser.uid )").child("Players").child("PlayersOf: \(specificTeam.teamName!)").child("\(playerNameToDelete.firstName!) \(playerNameToDelete.lastName!)").removeValue()
            //delete from playersArray
            self.players.remove(at: indexPath.row)
            //delete from tableview
            specificTeamTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
}
