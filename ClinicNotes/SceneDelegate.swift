//
//  SceneDelegate.swift
//  ClinicNotes
//
//  Created by Blezin on 03.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate, AuthServiceDelegate {

    var window: UIWindow?
    var authService: AuthService!
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)

    
  
    
    static func shared() -> SceneDelegate {
        let scene = UIApplication.shared.connectedScenes.first
        let sd: SceneDelegate = (((scene?.delegate as? SceneDelegate)!))
        return sd
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        authService = AuthService()
        authService.delegate = self
        let clinicVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        window?.rootViewController = clinicVC
        window?.makeKeyAndVisible()

    }
    
    func authServiceSignIn() {
        
        let titleClinic = NSLocalizedString("Clinics", comment: "")
        let titleRecents = NSLocalizedString("Recents", comment: "")
        let clinicVC = storyBoard.instantiateViewController(withIdentifier: "ClinicViewController") as! ClinicViewController
        let recentVC = storyBoard.instantiateViewController(withIdentifier: "RecentsViewController") as! RecentsViewController
        let navVC = UINavigationController(rootViewController: clinicVC)
        let recentNavVC = UINavigationController(rootViewController: recentVC)
        let tabBarController = UITabBarController()
        navVC.tabBarItem = UITabBarItem(title: titleClinic, image: UIImage(systemName: "table"), selectedImage: UIImage(systemName: "table.fill"))
        recentNavVC.tabBarItem = UITabBarItem(title: titleRecents, image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        tabBarController.viewControllers = [navVC, recentNavVC]
        window?.rootViewController = tabBarController

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

