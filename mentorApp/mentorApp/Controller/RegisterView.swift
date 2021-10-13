//
//  RegisterView.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/26/21.
//

import UIKit
import Firebase

class RegisterView: UIViewController {
    //MARK: - Screen Components
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorField: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = 20
    }
 
    var profile : Profile = Profile(firstName: "", lastName: "", phoneNumber: "", city: "", state: "", bio: "", type: "", career: "", categories: [])
    
    private func myDate() -> String{
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "h:mm a - MM/d/yy"
        let jDate = dateFormatter.string(from: currentDate)
        return jDate
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
 
        if let email = emailAddressField.text, let password = passwordField.text{
            if confirmPasswordField.text != passwordField.text {
                errorField.text = "Error: Passwords do not match"
            } else{
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error{
                        print(e.localizedDescription)
                        self.errorField.text = e.localizedDescription
                    } else{
                        
                        let docData: [String: Any] = [
                            
                            "email": email,
                            "firstName" : self.firstNameField.text!,
                            "lastName" : self.lastNameField.text!,
                            "phoneNumber" : self.phoneNumberField.text!,
                            "dateCreated" : self.myDate()

                        ]
                        ///guard let userID = Auth.auth().currentUser?.uid else {return}
                        Global.db.collection("userData").document(Global.userID!).setData(docData){ err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                        self.performSegue(withIdentifier: "RegisterToProfile", sender: self)
                    }
                }
            }
        }
    }
}
