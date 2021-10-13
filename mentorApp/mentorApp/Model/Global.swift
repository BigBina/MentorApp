//
//  Global.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/12/21.
//

import Foundation
import Firebase

class Global: NSObject {
    static let db = Firestore.firestore()
    static let userID = Auth.auth().currentUser?.uid
}
