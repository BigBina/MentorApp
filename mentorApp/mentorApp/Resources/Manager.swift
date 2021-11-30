//
//  Manager.swift
//  mentorApp
//
//  Created by Brandon Brown on 11/22/21.
//

import Foundation
import FirebaseFirestore
import Firebase

let database = Global.db.collection(Constants.FB.userData)

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Firestore.firestore()
    
    
    fileprivate func messageContent(_ firstMessage: Message, _ message: inout String) {
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
    }
    
    //MARK: - Method to get the Current User's Connections Conversations
    ///To be stored in the the Conversation and Lateset Message Struct
    public func getAllCoversations(for userID: String, completion: @escaping (Result<[Conversation],Error>) -> Void){
        let read = Global.db.collection(Constants.FB.userData).document("\(userID)")
        
        read.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                  }
            if let e = error{
                print(e.localizedDescription)
            } else {
         
                guard let pop = document.get(Constants.QueryKey.Conversations) as? [[String: Any]] else {
                      print("Document data was empty.")
                      return
                    }
               
                let convos : [Conversation] = pop.compactMap ({ dic in
                    guard let conversationID    = dic[Constants.QueryKey.ConversationID] as? String,
                       let name           = dic[Constants.QueryKey.Name] as? String,
                       let otherUserEmail = dic[Constants.QueryKey.OtherEmail] as? String,
                       let latestMessage  = dic[Constants.QueryKey.LatestMessage] as? [String: Any],
                       let sent           = latestMessage[Constants.QueryKey.DateOf] as? String,
                       let message        = latestMessage[Constants.QueryKey.LastMessage] as? String,
                       let isRead         = latestMessage[Constants.QueryKey.IsRead] as? Bool
                    else {
                        return nil
                    }
                        
                    let lastestMessage1 = LatestMessage(date: sent, text: message, isRead: isRead)
                    return Conversation(id: conversationID, name: name, otherUserEmail: otherUserEmail, latestMessage: lastestMessage1)
                    
                })
             
                completion(.success(convos))
                
            }
        }
    }
    
    //MARK: - Get all mesages for given converations
    public func getAllMessagesForConversation(with convo_id: String, completion: @escaping(Result<[Message],Error>) -> Void){
        let read = Global.db.collection(Constants.FB.userData).document(Global.userID!).collection("Convos").document("\(convo_id)")
        
        read.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                  }
            if let e = error{
                print(e.localizedDescription)
            } else {
         
                guard let pop = document.get("messages") as? [[String: Any]] else {
                      print("Document data was empty.")
                      return
                    }
               
                let messages : [Message] = pop.compactMap ({ dic in
                    guard let name = dic[Constants.QueryKey.Name] as? String,
                          let isRead      = dic[Constants.QueryKey.IsRead] as? Bool,
                          let messageID   = dic[Constants.QueryKey.MessageID] as? String,
                          let content     = dic["content"] as? String,
                          let senderEmail = dic[Constants.QueryKey.SenderEmail] as? String,
                          let dateString  = dic[Constants.QueryKey.DateOf] as? String,
                          let messageType = dic[Constants.QueryKey.MessageType] as? String,
                          let date        = ConversationsView.dateFormatter.date(from: dateString)
                    else {
                        return nil
                    }
                    let sender = Sender(senderId: senderEmail, displayName: name, photoURL: "")
                    return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
                            
                    
                })
             
                completion(.success(messages))
                
            }
        }
    }
    
    public func sendMessage(to otherUserEmail : String, message: Message, completion: @escaping(Result<[Message],Error>) -> Void){
        
        
    }
    
    //MARK: - Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String, completion: @escaping (Bool) -> Void){
        guard let currentUser = Global.profile.email else {return}
        
        let ref = Global.db.collection(Constants.FB.userData).document(Global.userID!)
        
        ref.getDocument { [weak self] documentSnapshot, err in
            guard var userNode = documentSnapshot?.data() else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ConversationsView.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            self?.messageContent(firstMessage, &message)
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData : [String: Any] = [
                
                Constants.QueryKey.ConversationID : conversationID,
                Constants.QueryKey.OtherEmail     : "\(otherUserEmail)",
                Constants.QueryKey.Name           : name,
                Constants.QueryKey.LatestMessage  :
                [
                    Constants.QueryKey.DateOf       : "\(dateString)",
                    Constants.QueryKey.LastMessage  : "\(message)",
                    Constants.QueryKey.IsRead       : false
                ]
                
            ]
            
            let recepient_newConversationData : [String: Any] = [
                
                Constants.QueryKey.ConversationID : conversationID,
                Constants.QueryKey.OtherEmail     : currentUser,
                Constants.QueryKey.Name           : Global.profile.firstName!,
                Constants.QueryKey.LatestMessage  :
                [
                    Constants.QueryKey.DateOf       : "\(dateString)",
                    Constants.QueryKey.LastMessage  : "\(message)",
                    Constants.QueryKey.IsRead       : false
                ]
                
            ]
            
            if var conversations = userNode[Constants.QueryKey.Conversations] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode[Constants.QueryKey.Conversations] = conversations
                ref.updateData(userNode) { [weak self] err in
                    if err != nil  {
                        completion(false)
                    } else {
                        print("conversations updated")
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, name: name, completion: completion)
                }
            } else {
                userNode[Constants.QueryKey.Conversations] = [
                    newConversationData
                ]
                
                ref.setData(userNode) { [weak self] err in
                    if err != nil  {
                        completion(false)
                    } else {
                        print("conversations updated")
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, name: name, completion: completion)
                }
            }
        }
        
    }
    //MARK: - Function that adds the data
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, name: String, completion: @escaping (Bool) -> Void){
        
        let messageDate = firstMessage.sentDate
        let dateString = ConversationsView.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        messageContent(firstMessage, &message)
        
        let messageForm: [String: Any] = [
            Constants.QueryKey.MessageID    : firstMessage.messageId,
            Constants.QueryKey.MessageType  : firstMessage.kind.MessageKindString,
            Constants.QueryKey.Content      : message,
            Constants.QueryKey.DateOf       : dateString,
            Constants.QueryKey.SenderEmail  : Global.profile.email!,
            Constants.QueryKey.IsRead       : false,
            Constants.QueryKey.Name         : name
        ]
        
        let value: [String: Any] = [
            "messages": [
                messageForm
            ]
        ]
            
        
        let ref = Global.db.collection(Constants.FB.userData).document(Global.userID!).collection("Convos").document("\(conversationID)")
        
        ref.setData(value) { err in
            guard err == nil else {
                completion(false)
                return
            }
            completion(true)
        }
   
        
    }
}
