//
//  MyUser.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import Firebase

struct MyUser {
    let email: String
    let displayName: String?
}

extension User {
    var myUser: MyUser {
        return MyUser(email: email ?? "", displayName: displayName)
    }
}
