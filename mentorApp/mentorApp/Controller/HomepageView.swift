//
//  HomepageView.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/22/21.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseStorageUI /// sd_setImage

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
    let user = Firebase.Auth.auth().currentUser
    let bop = Global.db.collection(Constants.FB.userData)
    let query = Global.db.collection(Constants.FB.userData).whereField(Constants.QueryKey.MentorshipType, isEqualTo: "Mentor")
    
    var docArrayStart = 0
    var mentor : MentorProfile = MentorProfile(firstName: nil, lastName: nil, email: "nil", city: nil, state: nil, bio: "nil", categories: ["nil"], career: "nil", picture: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        QueryMethod()
    }
    
    fileprivate func errorFunc(_ err: Error?) {
        if let err = err {
            print("Error updating document: \(err)")
        } else {
            print("Document successfully updated")
        }
    }


    //MARK: - Query Method
    func QueryMethod(){
        query.getDocuments() { querySnapshot, err in
            
            if let err = err {
                print("Error getting documents: \(err)")
          } else {
                guard self.docArrayStart < querySnapshot!.documents.count else {
                
                    let alert = UIAlertController(title: "Error", message: "Ran out of Users", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    return
                }
            //MARK: - Populate the page with Mentor Data
            if let document = querySnapshot?.documents[self.docArrayStart]{//0 - 1 -2
                let data = document.data()
                
                    if let firstN     = data[Constants.QueryKey.FirstName] as? String,
                       let lastN      = data[Constants.QueryKey.LastName] as? String,
                       let city       = data[Constants.QueryKey.City] as? String,
                       let state      = data[Constants.QueryKey.State] as? String,
                       let bio        = data[Constants.QueryKey.Bio] as? String,
                       let categories = data[Constants.QueryKey.Categories] as? [String],
                       let career     = data[Constants.QueryKey.Career] as? String,
                       let pic        = data[Constants.QueryKey.Picture] as? String,
                       let email      = data[Constants.QueryKey.Email] as? String
                      
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
                        
                        Global.db.collection(Constants.FB.userData).document(Global.userID!).updateData([
                            Constants.QueryKey.Count : self.docArrayStart
                        ]) { err in
                            self.errorFunc(err)
                        }
                        self.mentor.email = email
                     }
                }
                self.docArrayStart += 1
            
            }
        }
    }

    //MARK: - Deny and Accept Actions
    @IBAction func denyAction(_ sender: Any) {
        QueryMethod()
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        Global.db.collection(Constants.FB.userData).document(Global.userID!).updateData([
            Constants.QueryKey.Connections : FieldValue.arrayUnion([self.mentor.email])
        ]){ err in
            self.errorFunc(err)
        }

        DispatchQueue.main.async{
            self.listOfCategories.text = ""
        }

        QueryMethod()
    }

}
