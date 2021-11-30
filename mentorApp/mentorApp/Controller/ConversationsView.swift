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
    private let conversationID : String?
    public var isNewConversation = false
    
    
    private var selfSender : Sender?{
//        guard let email = Global.profile.email else {return nil}
//
//        let safeEmail = Constants.safeEmail(emailAdress: email)
        
        return Sender(senderId: Global.userID!,
               displayName: Global.profile.firstName!,
               photoURL: "Global.profile.picture")
    }
    
    private var messages = [Message]()
    

    ///initializing email
    init(with email: String, convo_id: String?) {
        self.otherUserEmail = email
        self.conversationID = convo_id
        super.init(nibName: nil, bundle: nil)
        if let id = conversationID {
            listenForMessages(convo_id: id, shouldScrollToBottom: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    

   private func listenForMessages(convo_id: String, shouldScrollToBottom: Bool){
        // Referencing a property on self in a closures, causes a retain cycle. Declaring weak self, makes the refernce weak, causing it not be a retain cycle.
        DatabaseManager.shared.getAllMessagesForConversation(with: convo_id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("Messages received \(messages)")
                guard !messages.isEmpty else {return}
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
    
            case .failure(let error):
                print("failure: \(error)")
            }
        })
    }
    

    
    private func createMessageID() -> String? {
        let dateString = Self.dateFormatter.string(from: Date())
//        guard let currentUserEmail = Global.profile.email else {return ""}
        let safeEmail = Constants.safeEmail(emailAdress: self.otherUserEmail)
        
        let newIdentifier = "\(safeEmail)_\(dateString)"
        return newIdentifier

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
            let message = Message(sender: selfSender,
                                  messageId: messageID,
                                  sentDate: Date(),
                                  kind: .text(text))
                DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title ?? "User", completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                } else {
                    print("Not sent")
                }
            })
        } else {
            //append to existing convo
           
        }
    }
}


//MARK: - TableView for the Messages
extension ConversationsView: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
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
