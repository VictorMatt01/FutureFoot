//
//  Team.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 23/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import Foundation
class Team {
    var teamName:String!
    var countPlayers:String!
    var players:[Player]!
    var coachName:String!
    
    init(initDic:NSDictionary) {
        self.teamName = initDic["teamName"] as! String
        self.players = []
        self.coachName = initDic["coachName"] as! String
    }
    
}
