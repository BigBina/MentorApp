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

    @IBOutlet weak var errorField: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    @IBAction func nextButton(_ sender: Any) {
 
        
        if let email = emailAddressField.text, let password = passwordField.text, let _ = firstNameField.text, let _ = lastNameField.text, let _ = phoneNumberField.text {
            if confirmPasswordField.text != passwordField.text {
                errorField.text = "Error: Passwords do not match"
            } else{
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error{
                        print(e.localizedDescription)
                    } else{
                        self.performSegue(withIdentifier: "RegisterToProfile", sender: self)
                    }
                }
            }
        
        } else{
            errorField.text = "Error: You are missing one of the required fields"
        }
    }
    
    



}
