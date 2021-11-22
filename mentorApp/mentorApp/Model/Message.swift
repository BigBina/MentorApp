//
//  Message.swift
//  mentorApp
//
//  Created by Brandon Brown on 11/12/21.
//

import Foundation
import MessageKit

struct Sender: SenderType {
        
    public var senderId: String
    public var displayName: String
    public var photoURL: String
    
}

struct Message: MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
}

extension MessageKind{
    var MessageKindString: String{
        switch self{
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
