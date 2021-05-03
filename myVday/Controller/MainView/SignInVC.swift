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
import Lottie

class SignInVC: UIViewController, FirebaseManagerDelegate {
    
    let firebaseManager = FirebaseManager.instance
    let sloganLabel = UILabel()
    let siwaButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseManager.delegate = self
        
        sloganLabel.numberOfLines = 0
        sloganLabel.text = "my ✌🏼 day\nVibrate the fresh\nVibration eVeryday."
        sloganLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 25)
        
        //lottie animation
        let animationView = AnimationView(name: "31454-food-prepared-food-app")
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        
        view.addSubview(animationView)
        view.addSubview(sloganLabel)
        
        animationView.loopMode = .loop
        animationView.play()
        
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        siwaButton.translatesAutoresizingMaskIntoConstraints = false
        
        // add the button to the view controller root view
        self.view.addSubview(siwaButton)
        
        // set constraint
        NSLayoutConstraint.activate([
            sloganLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sloganLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            sloganLabel.bottomAnchor.constraint(equalTo: animationView.topAnchor, constant: 70),
            
            siwaButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 85.0),
            siwaButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -85.0),
            siwaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0),
            siwaButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    @objc func appleSignInTapped() {
        startSignInWithAppleFlow()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var resultString = ""
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
                    resultString.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return resultString
    }
    
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
                let identityTokenString = String(data: idTokenData, encoding: .utf8) else { return }
            
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserIDCredential")
            if let _ = appleIDCredential.email,
                let givenName = appleIDCredential.fullName?.givenName,
                let _ = appleIDCredential.fullName?.familyName {
                
                // Initialize a Firebase credential.
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: identityTokenString,
                                                          rawNonce: nonce)
                
                // Sign in with Firebase.
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let err = error {
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
                            self.firebaseManager.addUser(loginUser: loginUser)
                        } else {
                            print("===========not a new user===========")
                        }
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                }
            } else {
                //不是第一次登入，但按過登出按鈕，email得到nil
                //存下userId後自動跳轉畫面到mainTabBar即可
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            }
        }
    }
}
