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

    
    private func myDate() -> String{
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "h:mm a - MM/d/yy"
        let formattedDate = dateFormatter.string(from: currentDate)
        return formattedDate
    }
    
    func buttonProperties(){
        nextButton.layer.cornerRadius = 20
        menteeButton.layer.cornerRadius = 20
        mentorButton.layer.cornerRadius = 20
    }
    
    //MARK: - Button Selectors
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

    //MARK: - Registration Portion w/ Firestore
    @IBAction func nextButton(_ sender: Any) {
        
        for button in buttonArray{
            if button.isSelected == true{
                Global.profile.type = button.currentTitle!
            }
        }
 
        if let email = emailAddressField.text, let password = passwordField.text{
            if confirmPasswordField.text != passwordField.text {
                
                let alert = UIAlertController(title: "Error", message: "Passwords do not match", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error{
                        
                        print(e.localizedDescription)
                        let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        Global.profile.firstName = self.firstNameField.text!
                        Global.profile.lastName = self.lastNameField.text!
                        Global.displayName = "\(Global.profile.firstName!) \(Global.profile.lastName!)"
                        Global.profile.email = email
                        
                        let docData: [String: Any] = [
                            
                            Constants.QueryKey.Filter         : Date().timeIntervalSince1970,
                            Constants.QueryKey.Email          : email,
                            Constants.QueryKey.FirstName      : self.firstNameField.text!,
                            Constants.QueryKey.LastName       : self.lastNameField.text!,
                            Constants.QueryKey.Phone          : self.phoneNumberField.text!,
                            Constants.QueryKey.Date           : self.myDate(),
                            Constants.QueryKey.MentorshipType : Global.profile.type

                        ]
                        ///guard let userID = Auth.auth().currentUser?.uid else {return}
                        Global.db.collection(Constants.FB.userData).document(Global.userID!).setData(docData){ err in
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
