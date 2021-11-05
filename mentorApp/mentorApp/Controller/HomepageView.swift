//
//  HomepageView.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/22/21.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseStorageUI

class HomepageView: UIViewController {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var listOfCategories: UILabel!
    @IBOutlet weak var bioDetails: UILabel!
    @IBOutlet weak var careerLabel: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    let defaults = UserDefaults.standard
    

    var docArrayStart = 0
    var num = 0
    var mentor : MentorProfile = MentorProfile(firstName: nil, lastName: nil, email: "nil", city: nil, state: nil, bio: "nil", categories: ["nil"], career: "nil")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        queryMethod()
        initalQuery()
    }
    
    
    
    
    var user = Firebase.Auth.auth().currentUser
    let query = Global.db.collection("userData").whereField("type", isEqualTo: "Mentor")

    func initalQuery(){
        query.getDocuments() { querySnapshot, err in
            
            self.num += 1
            print("Count of runtime \(self.num)")
            if let err = err {
                print("Error getting documents: \(err)")
          } else {
            guard self.docArrayStart < querySnapshot!.documents.count
            
            else{
                let alert = UIAlertController(title: "Error", message: "Ran out of Users", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)

                return
            }
            //MARK: - Populate the page with Mentor Data
            if let document = querySnapshot?.documents[self.docArrayStart]{//0 - 1 -2
                let data = document.data()
//                let mentorID = Firebase.Auth.auth().currentUser?.email
                    if let firstN = data["firstName"] as? String,
                       let lastN = data["lastName"] as? String,
                       let city = data["city"] as? String,
                       let state = data["state"] as? String,
                       let bio = data["bio"] as? String,
                       let categories = data["categories"] as? [String],
                       let career = data["career"] as? String,
                       let pic = data["profile-image"] as? String,
                       let email = data["email"] as? String
                      
                    {
                        let storageRef = Storage.storage().reference(forURL: pic)
                        self.profilePicture.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "\(Global.userID!).png"))
                        self.firstNameLabel.text = "\(firstN) \(lastN)"
                        self.cityStateLabel.text = "\(city), \(state)"
                        self.bioDetails.text = bio
                        self.careerLabel.text = career
                        
                        for category in categories {
                            self.listOfCategories.text! += "\(category)\n"
                        }
                        
                        
                        Global.db.collection("userData").document(Global.userID!).updateData([
                            "count" : self.docArrayStart
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                        //MARK: -
                        self.mentor.email = email
                        
                     }
                }
                self.docArrayStart += 1 //1 - 2 - 3
            }
        }
    }

    
    @IBAction func denyAction(_ sender: Any) {
        initalQuery()
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        Global.db.collection("userData").document(Global.userID!).updateData([
            "connections" : FieldValue.arrayUnion([self.mentor.email])
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        DispatchQueue.main.async{
            self.listOfCategories.text = ""
        }
        initalQuery()
    }
    
    
}
