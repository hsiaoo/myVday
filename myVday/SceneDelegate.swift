//
//  SceneDelegate.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/25.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
   
        if let userID = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            // get the login status of Apple sign in for the app
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID, completion: { credentialState, _ in
                switch credentialState {
                case .authorized:
                    print("user remain logged in, proceed to another view")
                    DispatchQueue.main.async {
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        self.window?.rootViewController = mainTabBarController
                    }
                case .revoked:
                    print("user logged in before but revoked")
                    DispatchQueue.main.async {
                        let loginNavController = storyboard.instantiateViewController(identifier: "SignInViewController")
                        self.window?.rootViewController = loginNavController
                    }
                case .notFound:
                    DispatchQueue.main.async {
                        let loginNavController = storyboard.instantiateViewController(identifier: "SignInViewController")
                        self.window?.rootViewController = loginNavController
                    }
                default:
                    print("unknown state")
                }
            })
        }
        
    }
    
    func changeRootViewController(_ viewcontroller: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        // change the root view controller to your specific view controller
        window.rootViewController = viewcontroller
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
