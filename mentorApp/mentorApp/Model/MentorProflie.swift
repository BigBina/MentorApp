//
//  MentorProflie.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/26/21.
//

import Foundation
import UIKit

struct MentorProfile: Equatable {
    var firstName : String?
    var lastName : String?
    var email : String?
    var city : String?
    var state : String?
    var bio : String
    // Mentor or mentee
    // All selected will from categories page will be here
    var categories : [String]
//    var interest : [String]
    // This is seperate. Only choose 1 from the picker view.
    var career : String
    
    var picture : UIImage?
    
    static func == (storedConnection: MentorProfile, newConnection: MentorProfile) -> Bool {
        return storedConnection.email == newConnection.email
    }
}
