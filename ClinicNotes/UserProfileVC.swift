//
//  UserProfileVC.swift
//  My Labix
//
//  Created by Alex Stepanov on 28.02.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn


class UserProfileVC: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32,
                              y: view.frame.height - 172,
                              width: view.frame.width - 64,
                              height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    

        override func viewDidLoad() {
            super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
      
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
}

extension UserProfileVC {
    
    private func openLoginViewController() {
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
            
        } catch let error {
            print("Failed to sign out with error: ", error.localizedDescription)
        }
    }

    
    @objc private func signOut() {
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did log out of facebook")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                    print("User did log out of google")
                    openLoginViewController()
                case "password":
                    try! Auth.auth().signOut()
                    print("User did sing out")
                    openLoginViewController()
                default:
                    print("User is signed in with")
                }
            }
        }
    }

}
