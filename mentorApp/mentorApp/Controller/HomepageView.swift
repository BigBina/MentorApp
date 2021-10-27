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
    
    
    

    var docArrayStart = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        queryMethod()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    var user = Firebase.Auth.auth().currentUser


    func queryMethod(){
        
        let typeRef = Global.db.collection("userData")
        let query = typeRef.whereField("type", isEqualTo: "Mentor")
        
        query.getDocuments { querySnapshot, err in
          
            if let err = err {
                print("Error getting documents: \(err)")
          } else {
            guard self.docArrayStart < querySnapshot!.documents.count
            
            else{
                let alert = UIAlertController(title: "Error", message: "Ran out of Users", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.acceptButton.isHidden = true
                self.denyButton.isHidden = true
                return
            }
                if let document = querySnapshot?.documents[self.docArrayStart]{//0 - 1 -2
                    let data = document.data()
                    if let firstN = data["firstName"] as? String,
                       let lastN = data["lastName"] as? String,
                       let city = data["city"] as? String,
                       let state = data["state"] as? String,
                       let bio = data["bio"] as? String,
                       let categories = data["categories"] as? [String],
                       let career = data["career"] as? String,
                       let pic = data["profile-image"] as? String
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
                     }
                    print("\(document.documentID) => \(document.data())")
                }
                self.docArrayStart += 1 //1 - 2 - 3
            }
        }
    }
    
    @IBAction func denyAction(_ sender: Any) {
        queryMethod()
        self.listOfCategories.text = ""
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        queryMethod()
        self.listOfCategories.text = ""

    }
    
}
