//
//  ViewController.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/26/21.
//

import UIKit
import AuthenticationServices

class LandingView: UIViewController {

    @IBOutlet weak var appleViewButton: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    private let sign = ASAuthorizationAppleIDButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buttonProperties()
    }
    
    func buttonProperties(){
        
        view.addSubview(sign)
        sign.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        self.appleViewButton.addArrangedSubview(sign)
        sign.cornerRadius = 20
        registerButton.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sign.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        
    }
    
    @objc func didTapSignIn(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    

}

extension LandingView: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Woah")
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
            let firstName = appleIDCredential.fullName?.givenName
            let lastName = appleIDCredential.fullName?.familyName
            let email = appleIDCredential.email
            break
        
        default:
            break
        }
    
    }
}

extension LandingView: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}
