//
//  AccountInfo.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/28/21.
//

import Foundation

struct Profile {
    var firstName : String
    let lastName : String
    var phoneNumber : String
    let city : String
    let state : String
    let bio : String
    // Mentor or mentee
    let type : String
    // All selected will from categories page will be here
    var categories : [String]
//    var interest : [String]
    // This is seperate. Only choose 1 from the picker view.
    var career : String
    
}


