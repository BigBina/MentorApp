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
    static let userEmail = Auth.auth().currentUser?.email
    static var displayName = Auth.auth().currentUser?.displayName
    
    static var profile : Profile = Profile(firstName: "", lastName: "", phoneNumber: "", city: "", state: "", bio: "", email: "", type: "", career: "", categories: [""], picture: "")
    static var MentorProf : MentorProfile = MentorProfile(firstName: "", lastName: "", email: "", city: "", state: "", bio: "", categories: [""], career: "", picture: nil)
}
