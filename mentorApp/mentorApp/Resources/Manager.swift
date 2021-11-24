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
                    guard let conversationID = dic[Constants.QueryKey.ConversationID] as? String,
                       let name = dic[Constants.QueryKey.Name] as? String,
                       let otherUserEmail = dic[Constants.QueryKey.OtherEmail] as? String,
                       let latestMessage = dic[Constants.QueryKey.LatestMessage] as? [String: Any],
                       let sent = latestMessage[Constants.QueryKey.DateOf] as? String,
                       let message = latestMessage[Constants.QueryKey.LastMessage] as? String,
                       let isRead = latestMessage[Constants.QueryKey.IsRead] as? Bool
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
    
    ///Get all mesages for given converations
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
                          let isRead = dic[Constants.QueryKey.IsRead] as? Bool,
                          let messageID = dic[Constants.QueryKey.MessageID] as? String,
                          let content = dic["content"] as? String,
                          let senderEmail = dic[Constants.QueryKey.SenderEmail] as? String,
                          let dateString = dic[Constants.QueryKey.DateOf] as? String,
                          let messageType = dic[Constants.QueryKey.MessageType] as? String,
                          let date = ConversationsView.dateFormatter.date(from: dateString)
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
}
