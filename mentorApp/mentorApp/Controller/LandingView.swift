//
//  ViewController.swift
//  mentorApp
//
//  Created by Brandon Brown on 9/26/21.
//

import UIKit
import AuthenticationServices
import Firebase
import CryptoKit

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sign.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
    }
    
    func buttonProperties(){
        
        view.addSubview(sign)
        sign.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        self.appleViewButton.addArrangedSubview(sign)
        sign.cornerRadius = 20
        registerButton.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
    }
    

    fileprivate var currentNonce: String?
    @objc func didTapSignIn(){
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()
        return hashString
        
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
//MARK: - Apple Authorization
extension LandingView: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Woah")
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential.
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
          // Sign in with Firebase.
          Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
            if let e = error {
              print(e.localizedDescription)
            }
          }
        }
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:


            //Create an account in your system.
            let user = Apple(appleIDCredentials: appleIDCredential)
            if user.email != ""{
                self.performSegue(withIdentifier: "AppleToRegister", sender: self)
            } else {
                self.performSegue(withIdentifier: "AppleToMain", sender: self)
            }
        
            break
        default:
            break
        }
    
    }
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}

extension LandingView: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
}

