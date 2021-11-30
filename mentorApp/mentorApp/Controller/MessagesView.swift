//
//  MessagesView.swift
//  mentorApp
//
//  Created by Brandon Brown on 11/2/21.
//

import UIKit
import Firebase
import FirebaseStorageUI

class MessagesView: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var imgView = UIImageView()
    var completion: ((MentorProfile) -> (Void))?
    
    private var conversations = [Conversation]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //This is how we register the nib that we created
        tableView.register(UINib(nibName: "MessagesCell", bundle: nil), forCellReuseIdentifier: "MessageIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        
        grabArrayFunc()
        listenToConversations()
        
    }
    
    var connections : [MentorProfile] = []
    var connect : [String] = []
    let arr = Global.db.collection(Constants.FB.userData).document(Global.userID!)
    
    private func completionFunc(){
        completion = { [weak self] result in
            print("This is the result from the completion: \(result)")
            self?.createNewConvco(result: result)
        }
    }
    
    private func listenToConversations (){
        DatabaseManager.shared.getAllCoversations(for: Global.userID!, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("Yo sum not right")
                    return
                    
                }
                
                print("gets here")
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("fail: \(error)")
            }
        })
    }
    
    
    private func createNewConvco(result: MentorProfile){
        guard let fName = result.firstName, let lName = result.lastName, let email = result.email else {return}
        
        let vc = ConversationsView(with: email, convo_id: nil)
        vc.isNewConversation = true
        //Go back and make the mentor profile a global function
        vc.title = "\(fName) \(lName)"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
  
    func grabArrayFunc() {
        
        self.connect = []
        
//        let grabArray = Global.db.collection(Constants.FB.userData)
        self.arr.addSnapshotListener(includeMetadataChanges: true) { docSnapshot, err in
            if let err = err {
                 print("Error getting documents: \(err)")
             } else {
                if let document = docSnapshot?.data(),
                   let doc = document[Constants.QueryKey.Connections] as? [String] {
                    self.connect = doc
                    for connectionsMatches in doc {
                        if self.connect.contains(connectionsMatches){
                            continue
                        } else {
                            self.connect.append(connectionsMatches)
                        }
        
                    }

                }
                
             }
            
            self.loadConnections()
        }
    }
    
    func loadConnections(){
        for users in self.connect{
            let query = Global.db.collection(Constants.FB.userData).whereField(Constants.QueryKey.Email, isEqualTo: users)
            self.connections = []
            query.addSnapshotListener { querySnapshot, error in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore \(e)")
                } else{
                    //Checks to see if the query inst nil
                    if let snapshotDocuments = querySnapshot?.documents {
                        // going through each of the docs
                        for doc in snapshotDocuments {
                            //and setting data to the data that with the doc
                            let data = doc.data()
                         
                            if let connectionFirstName  = data[Constants.QueryKey.FirstName] as? String,
                               let connectionLastName   = data[Constants.QueryKey.LastName] as? String,
                               let connectionEmail      = data[Constants.QueryKey.Email] as? String,
                               let connectionPicture    = data[Constants.QueryKey.Picture] as? String {
                                
                                let storageRef = Storage.storage().reference(forURL: connectionPicture)
                                self.imgView.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "\(Global.userID!).png)"))
                               
                                
                                let newConnection = MentorProfile(firstName: connectionFirstName, lastName: connectionLastName, email: connectionEmail, city: "", state: "", bio: "", categories: [""], career: "", picture: self.imgView.image)
                                
                                self.connections.append(newConnection)

                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                               }
                            } else {
                                print("This aint working playboy")
                            }
                        }
                    }
                }
            }
        }
    }


}
//MARK: - Messages TableView
extension MessagesView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let connection = connections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageIdentifier", for: indexPath) as! MessagesCell
        
        cell.accessoryType = .disclosureIndicator
        cell.nameLabel?.text = "\(connection.firstName!) \(connection.lastName!)"
        cell.profileImage.image = connection.picture
        cell.recentMessage.text = "Start a conversation..."

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        let vc = ConversationsView(with: model.otherUserEmail, convo_id: model.id)
        completionFunc()
        vc.title = model.name
        let targetUser = connections[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUser)
        })
        
    }
    
}
