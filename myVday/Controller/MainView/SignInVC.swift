//
//  SignInVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/17.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

class SignInVC: UIViewController, FirebaseManagerDelegate {
    
    let fireManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fireManager.delegate = self
        
        let siwaButton = ASAuthorizationAppleIDButton()
        
        siwaButton.translatesAutoresizingMaskIntoConstraints = false
        
        // add the button to the view controller root view
        self.view.addSubview(siwaButton)
        
        // set constraint
        NSLayoutConstraint.activate([
            siwaButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
            siwaButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
            siwaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0),
            siwaButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
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
    
     // Unhashed nonce.
     fileprivate var currentNonce: String?

     @available(iOS 13, *)
     func startSignInWithAppleFlow() {
       let nonce = randomNonceString()
       currentNonce = nonce
       let appleIDProvider = ASAuthorizationAppleIDProvider()
       let request = appleIDProvider.createRequest()
        // request full name and email from the user's Apple ID
       request.requestedScopes = [.fullName, .email]
       request.nonce = sha256(nonce)

        // pass the request to the initializer of the controller
       let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        // delegate functions will be called when user data is
        // successfully retrieved or error occured
       authorizationController.delegate = self
        // similar to delegate, this will ask the view controller
        //  which window to present the ASAuthorizationController
       authorizationController.presentationContextProvider = self
        // show the Sign-in with Apple dialog
       authorizationController.performRequests()
     }

     @available(iOS 13, *)
     private func sha256(_ input: String) -> String {
       let inputData = Data(input.utf8)
       let hashedData = SHA256.hash(data: inputData)
       let hashString = hashedData.compactMap {
         return String(format: "%02x", $0)
       }.joined()

       return hashString
     }
    
    @objc func appleSignInTapped() {
        startSignInWithAppleFlow()
    }
    
    func encode(emoji: String) -> String {
        if  let data = emoji.data(using: .nonLossyASCII, allowLossyConversion: true), let emojiString = String(data: data, encoding: .utf8) {
            return emojiString
        }
        return "can not encode the emoji"
    }
    
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
        case .failed:
            // authorization failed
            print("Failed")
        @unknown default:
            print("Default")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
              fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let idTokenData = appleIDCredential.identityToken,
                let identityTokenString = String(data: idTokenData, encoding: .utf8)
                else { return }
            
//            if let code = appleIDCredential.authorizationCode, let authorizationCode = String(bytes: code, encoding: .utf8) {
//                UserDefaults.standard.set(authorizationCode, forKey: "userAuthorizationCode")
//            }
            
            // 'appleIDCredential.user' is a unique ID for each user, this uniqueID will always be returned
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserIDCredential")
            guard let email = appleIDCredential.email,
                let givenName = appleIDCredential.fullName?.givenName,
                let familyName = appleIDCredential.fullName?.familyName else { return }
            print("userId: \(appleIDCredential.user), email: \(email), givenName: \(givenName), familyName: \(familyName)")
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: identityTokenString,
                                                      rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let err = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(err.localizedDescription)
                    print(err)
                    return
                } else {
                    if let isNewUser = authResult?.additionalUserInfo?.isNewUser,
                        isNewUser == true {
                            // User is signed in to Firebase with Apple.
                            let emojiString = self.encode(emoji: "😃")
                            let loginUser = User(
                                userId: appleIDCredential.user,
                                nickname: givenName,
                                describe: "Hello!",
                                emoji: emojiString,
                                image: "")
                            self.fireManager.addUser(loginUser: loginUser)
                        } else {
                            print("===========not a new user===========")
                    }
                }
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            
            // This is to get the SceneDelegate object from your view controller
            // then call the change root view controller function to change to main tab bar
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        }
    }
}
