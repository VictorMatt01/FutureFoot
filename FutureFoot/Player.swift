//
//  Player.swift
//  FutureFoot
//
//  Created by Victor Matthijs on 23/08/2018.
//  Copyright © 2018 Victor Matthijs. All rights reserved.
//

import Foundation

class Player {
    var firstName:String!
    var lastName:String!
    var email:String!
    var birthday:String!
    
    init(initDic:NSDictionary) {
        self.firstName = initDic["firstName"] as! String
        self.lastName = initDic["lastName"] as! String
        self.email = initDic["email"] as! String
        self.birthday = initDic["birthday"] as! String
    }
    
}
