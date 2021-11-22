//
//  ConversationsView.swift
//  mentorApp
//
//  Created by Brandon Brown on 11/2/21.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView


class ConversationsView: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .long
        format.locale = .current
        return format
    }()
    
    public let otherUserEmail : String
    public var isNewConversation = false
    
    
    private var selfSender : Sender?{
        guard let email = Global.profile.email else {return nil}
        
       return Sender(senderId: email,
               displayName: Global.profile.firstName!,
               photoURL: Global.profile.picture)
    }
    
    var messages = [Message]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Yo")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
     
    }

    override func viewDidAppear(_ animated: Bool) {
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    ///initializing email
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createMessageID() -> String? {
        let dateString = Self.dateFormatter.string(from: Date())
//        guard let currentUserEmail = Global.profile.email else {return ""}
        let safeEmail = Constants.safeEmail(emailAdress: self.otherUserEmail)
        
        let newIdentifier = "\(safeEmail)_\(dateString)"
        return newIdentifier
        
    }
    
    
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
 


}

//MARK: - Sending Messages (Text only)
extension ConversationsView: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageID = createMessageID() else {
            return
        }
        print("\(text)")
        
        if isNewConversation {
            let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title ?? "User") { success in
                if success {
                    print("message sent")
                } else {
                    print("Not sent")
                }
            }
        } else {
            //append to existing convo
        }
    }

}


//MARK: - TableView for the Messages
extension ConversationsView: MessagesLayoutDelegate, MessagesDataSource, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
//        fatalError("Self sender is nil, email should be there.")
        return Sender(senderId: "12", displayName: "", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

//MARK: - Initializers for Conversation and Messages (Reading & Writing)
extension ConversationsView {
    
    ///Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String, completion: @escaping (Bool) -> Void){
        guard let currentUser = Global.profile.email else {return}
        
        let ref = Global.db.collection(Constants.FB.userData).document(Global.userID!)
        
        ref.getDocument { documentSnapshot, err in
            guard var userNode = documentSnapshot?.data() else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ConversationsView.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            self.messageContent(firstMessage, &message)
            
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
            
            if var conversations = userNode[Constants.QueryKey.Conversations] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode[Constants.QueryKey.Conversations] = conversations
                ref.updateData(userNode) { err in
                    if err != nil  {
                        completion(false)
                    } else {
                        print("conversations updated")
                    }
                    self.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, name: name, completion: completion)
                }
            } else {
                userNode[Constants.QueryKey.Conversations] = [
                    newConversationData
                ]
                
                ref.setData(userNode) { err in
                    if err != nil  {
                        completion(false)
                    } else {
                        print("conversations updated")
                    }
                    self.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, name: name, completion: completion)
                }
            }
        }
        
    }
    
    
    
    
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
    
    ///Fetches and returns all coversations associated with the user's passed in email
    public func getAllCoversations(for email: String, completion: @escaping (Result<String,Error>) -> Void){
       
    }
    
    ///Get all mesages for given converations
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<String,Error>) -> Void){
        
    }
    
    ///Send a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Bool) -> Void){
        
    }
}

//1st insert new conversation
//2nd return all conversations for a given user
// return all messages for a given coversation
