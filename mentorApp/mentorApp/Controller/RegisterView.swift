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
    @IBOutlet weak var menteeButton: UIButton!
    @IBOutlet weak var mentorButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorField: UILabel!
    
    var buttonArray : [UIButton] = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        buttonProperties()
        
        self.buttonArray = [self.menteeButton, self.mentorButton]
    }

 
    var profile : Profile = Profile(firstName: "", lastName: "", phoneNumber: "", city: "", state: "", bio: "", type: "", career: "", categories: [])
    
    private func myDate() -> String{
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "h:mm a - MM/d/yy"
        let jDate = dateFormatter.string(from: currentDate)
        return jDate
    }
    
    func buttonProperties(){
        nextButton.layer.cornerRadius = 20
        menteeButton.layer.cornerRadius = 20
        mentorButton.layer.cornerRadius = 20
    }
    
    @IBAction func menteeButton(_ sender: UIButton) {
        if menteeButton.isSelected == false{
            menteeButton.isSelected = true
            menteeButton.isHighlighted = true
            menteeButton.backgroundColor = .link
            mentorButton.isHidden = true
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            menteeButton.isSelected = false
            menteeButton.isHighlighted = false
            menteeButton.backgroundColor = .systemBackground
            mentorButton.isHidden = false
            //remove it from the profile struct
            print("Not highlighted")
        }

    }
    
    @IBAction func mentorButton(_ sender: UIButton) {
        if mentorButton.isSelected == false{
            mentorButton.isSelected = true
            mentorButton.isHighlighted = true
            mentorButton.backgroundColor = .link
            menteeButton.isHidden = true
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            mentorButton.isSelected = false
            mentorButton.isHighlighted = false
            mentorButton.backgroundColor = .systemBackground
            menteeButton.isHidden = false
            //remove it from the profile struct
            print("Not highlighted")
        }
        
        

    }

    
    @IBAction func nextButton(_ sender: Any) {
        
        for button in buttonArray{
            if button.isSelected == true{
                profile.type = button.currentTitle!
            }
        }
 
        if let email = emailAddressField.text, let password = passwordField.text{
            if confirmPasswordField.text != passwordField.text {
                errorField.text = "Error: Passwords do not match"
            } else{
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error{
                        print(e.localizedDescription)
                        self.errorField.text = e.localizedDescription
                    } else{
                        self.profile.firstName = self.firstNameField.text!
                        
                        let docData: [String: Any] = [
                            
                            "filterDate": Date().timeIntervalSince1970,
                            "email": email,
                            "firstName" : self.firstNameField.text!,
                            "lastName" : self.lastNameField.text!,
                            "phoneNumber" : self.phoneNumberField.text!,
                            "dateCreated" : self.myDate(),
                            "type" : self.profile.type

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
