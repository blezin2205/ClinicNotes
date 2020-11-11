//
//  ClinicNetworkService.swift
//  ClinicNotes
//
//  Created by Blezin on 26.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FBSDKLoginKit
import GoogleSignIn


protocol ClinicNetworkServiceDelegate {
    
    func logOut(from viewController: UIViewController)
    func getClinicSnapshot(completion: @escaping(GetClinicResponse) -> ())
    func saveClinicIntoFirebase(imageIsChanged: Bool, selectedClinic: Clinic?, textField: DetailClinicTextFieldDelegate)
    var ref: DatabaseReference? { get }
}

protocol DetailClinicTextFieldDelegate {
    
    var image: UIImage? {get}
    var name: String {get}
    var location: String? {get}
    var city: String? {get}
    var longitude: String? {get}
    var latitude: String? {get}
    
}


struct ClinicNetworkService: ClinicNetworkServiceDelegate {

    
     let ref: DatabaseReference? = Database.database().reference(withPath: "Cliniks")
     func getClinicSnapshot(completion: @escaping(GetClinicResponse) -> ()) {
        
        FIRNetworkService.shared.getSnapshot(ref: ref) { (snapshot) in
            let response =  GetClinicResponse.init(snapshot: snapshot)
                completion(response)
          
        }
    }
    
    
    func saveClinicIntoFirebase(imageIsChanged: Bool, selectedClinic: Clinic?, textField: DetailClinicTextFieldDelegate) {
        
        if selectedClinic != nil {
            
            selectedClinic?.ref?.updateChildValues(["name": textField.name,
                                                           "location": textField.location ?? "",
                                                           "city": textField.city ?? ""])
            
            if imageIsChanged {
                DispatchQueue.main.async {
                    self.uploadPhoto(clinicImage: textField.image) { (url) in
                        selectedClinic?.ref?.updateChildValues(["image": url])
                    }
                }
            }
            
            
        } else {
            
            let user = Auth.auth().currentUser?.displayName
            let firClinic = Clinic.init(name: textField.name,
                                           location: textField.location,
                                           city: textField.city, image: nil,
                                           userId: user ?? "",
                                           longitude: textField.longitude, latitude: textField.latitude)
            ref?.child(textField.name).setValue(firClinic.convertToDictionary())
            
            if imageIsChanged {
                DispatchQueue.main.async {
                    self.uploadPhoto(clinicImage: textField.image) { (url) in
                        self.ref?.child(textField.name).updateChildValues(["image": url])
                    }
                }
            }
            
        }
        
        
    }
    
   private func uploadPhoto(clinicImage: UIImage?, completion: @escaping (_ url: String)->()) {
        
        guard let image = clinicImage, let data = image.jpegData(compressionQuality: 0.5) else {return}
        
        let imageName = UUID().uuidString
        
        let imageReference = Storage.storage().reference().child("MyPhoto").child(imageName)
        
        
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            imageReference.downloadURL { (url, error) in
                guard let url = url, error == nil else {return}
                
                let urlString = url.absoluteString
                completion(urlString)
            }
        }
        
    }

    
    private func openLoginViewController(viewController: UIViewController) {
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                viewController.present(loginViewController, animated: true)
                return
            }
            
        } catch let error {
            viewController.showAlert(title: "LogOut Error!", message: error.localizedDescription)
        }
    }
    
    
     func logOut(from viewController: UIViewController) {
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did log out of facebook")
                    openLoginViewController(viewController: viewController)
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                    print("User did log out of google")
                    openLoginViewController(viewController: viewController)
                case "password":
                    try! Auth.auth().signOut()
                    print("User did sing out")
                    openLoginViewController(viewController: viewController)
                default:
                    viewController.showAlert(title: "Error", message: "Unable to LogOut!")
                }
            }
        }
    }
    
    
}
