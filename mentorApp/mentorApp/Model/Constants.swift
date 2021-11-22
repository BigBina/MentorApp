//
//  Constants.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/28/21.
//

import Foundation

struct Constants {
    struct FB {
        static let userData = "userData"
    }
    
    struct QueryKey {
        
        static let MentorshipType = "type"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let City = "city"
        static let State = "state"
        static let Bio = "bio"
        static let Categories = "categories"
        static let Career = "career"
        static let Picture = "profile-image"
        static let Email = "email"
        static let Date = "dateCreated"
        static let Count = "count"
        static let Connections = "connections"
        static let Phone = "phoneNumber"
        static let Filter = "filterDate"
        
        static let Conversations = "conversations"
        static let ConversationID = "conversation_id"
        static let MessageID = "message_id"
        static let OtherEmail = "other_user_email"
        static let Name = "name"
        static let MessageType = "message_type"
        static let LatestMessage = "latest_message"
        static let Content = "content"
        static let DateOf = "date"
        static let LastMessage = "last_message"
        static let IsRead = "is_read"
        static let SenderEmail = "sender_email"
        
    }
    
    
    static func safeEmail(emailAdress: String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


