//
//  AccountInfo.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/28/21.
//

import Foundation

public struct Profile {
    var firstName : String?
    var lastName : String?
    var phoneNumber : String?
    var city : String?
    var state : String?
    var bio : String?
    var email : String?
    // Mentor or mentee
    var type : String
    // All selected will from categories page will be here
    var categories : [String]
//    var interest : [String]
    // This is seperate. Only choose 1 from the picker view.
    var career : String
    
    var picture : String
    
    init(firstName: String, lastName: String, phoneNumber: String, city: String, state: String, bio: String, email: String ,type: String, career: String ,categories: [String], picture: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.career = career
        self.phoneNumber = phoneNumber
        self.city = city
        self.state = state
        self.type = type
        self.categories = categories
        self.career = career
        self.bio = bio
        self.picture = picture
    }
}


