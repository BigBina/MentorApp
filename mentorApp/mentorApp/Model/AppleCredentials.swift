//
//  AppleCredentials.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/28/21.
//

import Foundation
import AuthenticationServices

struct Apple{
    let user : String
    let firstName : String
    let lastName : String
    let email : String
    
    init(appleIDCredentials: ASAuthorizationAppleIDCredential){
        self.user = appleIDCredentials.user
        self.firstName = appleIDCredentials.fullName?.givenName ?? ""
        self.lastName = appleIDCredentials.fullName?.familyName ?? ""
        self.email = appleIDCredentials.email ?? ""
    }
}

