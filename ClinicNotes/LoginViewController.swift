//
//  LoginViewController.swift
//  Networking
//
//  Created by Alex Stepanov on 10.02.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    var labelEmpty = true
    var slogan = "ClinicNotes App. Welcome!"
    
    
    lazy var customFBLoginButton: UIButton = {
        
        let icon = UIImage(named: "icons8-facebook")!
        
        let loginButton = UIButton()
        
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.frame = CGRect(x: 32, y: view.frame.maxY - 260, width: view.frame.width - 64, height: 50)
        loginButton.setImage(icon, for: .normal)
        loginButton.imageView?.contentMode = .scaleAspectFit
        loginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        loginButton.applyGradient(colors: [primaryColor.cgColor, primaryColor.cgColor])
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    
    lazy var customGoogleLoginButton: UIButton = {
        
        let icon = UIImage(named: "icons8-google")!
        
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: view.frame.maxY - 200, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Login with Google", for: .normal)
        loginButton.setImage(icon, for: .normal)
        loginButton.imageView?.contentMode = .scaleAspectFit
        loginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -35, bottom: 0, right: 0)
        loginButton.applyGradient(colors: [primaryColor.cgColor, primaryColor.cgColor])
        
        loginButton.addTarget(self, action: #selector(handleCustomGoogleLogin), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var signInWithEmail: UIButton = {
        
        let icon = UIImage(named: "icons8-email")!
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: view.frame.maxY - 80, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.setImage(icon, for: .normal)
        loginButton.imageView?.contentMode = .scaleAspectFit
        loginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -36, bottom: 0, right: 0)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
        return loginButton
    }()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if labelEmpty {
            
            let sloganArray = slogan.components(separatedBy: " ")
            var i = 0.0
            for word in sloganArray{
                
                let label = UILabel(frame: CGRect(x: -200, y: view.frame.height/4 + CGFloat(i*110), width: 220, height: 80))
                label.font = .boldSystemFont(ofSize: 40)
                label.contentMode = .scaleToFill
                label.textAlignment = .center
                label.highlightedTextColor = .black
                label.text = word
                label.textColor = .white
                label.highlightedTextColor = .black
                label.textDropShadow()
                label.center.x = view.center.x
                label.center.x -= view.bounds.width
                view.addSubview(label)
                UIView.animate(withDuration: 0.7, delay: i, options: .curveEaseOut, animations: {
                    
                    label.center.x += self.view.bounds.width
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    
                    
                })
                
                i+=0.5
            }
            labelEmpty = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        setupViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        
        view.addSubview(customGoogleLoginButton)
        view.addSubview(signInWithEmail)
        view.addSubview(customFBLoginButton)
        
        
    }
    @objc private func openSignInVC() {
        performSegue(withIdentifier: "SignIn", sender: self)
    }
    
}

// MARK: Facebook SDK

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            return
        }
        guard AccessToken.isCurrentAccessTokenActive else { return }
        signIntoFirebase()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    private func openMainViewController() {
        
        self.dismiss(animated: true, completion: nil)
        
        
        
        
    }
    
    // *** FacebookCustomLoginButton ***
    
    @objc private func handleCustomFBLogin() {
        
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.signIntoFirebase()
                self.openMainViewController()
            }
        }
    }
    
    // *** FacebookCustomLoginButton ***
    
    @objc private func handleCustomGoogleLogin() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    private func signIntoFirebase() {
        
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error sign in with Firebase", error)
            }
            print("User sign in Firebase with Facebook")
            self.fetchFacebookFields()
            
        }
    }
    
    private func fetchFacebookFields() {
        
        GraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"]).start { (_, result, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print(self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
            }
        }
        
    }
    
    private func saveIntoFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        
        let values = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in
            if let error = error {
                print(error)
                return
            }
            
            print("Successfully saved user into FirebaseDatabase")
            self.openMainViewController()
            
            
        }
    }
    
    
}

// MARK: Google SDK

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Failed to logg into Google", error)
            return
        }
        print("Successfuly loged in to Google")
        
        if let userName = user.profile.name, let userEmail = user.profile.email {
            let userData = ["name": userName, "email": userEmail]
            userProfile = UserProfile(data: userData)
        }
        
        
        
        
        
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Something went wrong with our Google user", error)
                return
            }
            print("Successfully logged into Firebase with Google")
            self.saveIntoFirebase()
            
        }
        
    }
    
    
}


