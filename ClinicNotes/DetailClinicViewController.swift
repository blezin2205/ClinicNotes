//
//  DetailViewController.swift
//  Clinic Notes
//
//  Created by Blezin on 24.09.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage

class DetailViewController: UITableViewController {
    

    var selectedClinic: (image: UIImage, clinic: FIRClinic)?
    var ref: DatabaseReference?
    
    var imageIsChanged = false
    var longitude: String?
    var latitude: String?
    var incomeSegue = ""
    

    @IBOutlet weak var clinicImage: UIImageView!
    @IBOutlet weak var clinicName: UITextField!
    @IBOutlet weak var clinicLocation: UITextField!
    @IBOutlet weak var clinicCity: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var showAddress: UIButton!
    @IBOutlet weak var getAddress: UIButton!
    
    @IBOutlet weak var createdByLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = MyRef.reference
        
        if incomeSegue == "edit" {
            createdByLabel.text = "created by \(selectedClinic!.clinic.userId )"
            createdByLabel.font = .italicSystemFont(ofSize: 13)
        }
       
        navigationController?.navigationBar.prefersLargeTitles = false
        saveButton.isEnabled = false
        clinicName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
 

    
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func showCurrentClinicLocation(_ sender: Any) {
        
        let latitude = self.latitude != nil ?  self.latitude :  selectedClinic?.clinic.latitude
        let longitude = self.longitude != nil ?  self.longitude :  selectedClinic?.clinic.longitude
        guard let _latitude = latitude, let _longitude = longitude else {
            showAlert(title: "Error", message: "Location not exist or empty")
            return }
        
      if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
        UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(_latitude),\(_longitude)&directionsmode=driving")!)
      }
      else {
        showAlert(title: "GoogleMaps", message: "Can't use comgooglemaps://")
          
      }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let mapVC = segue.destination as? GooglemapVC else { return }
        mapVC.mapViewControllerDelegate = self
        mapVC.clinic = selectedClinic?.clinic
        print("to googlemap")
    }
    
    
    
    
    
     func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    func uploadPhoto(completion: @escaping (_ url: String)->()) {
        
        guard let image = clinicImage.image, let data = image.jpegData(compressionQuality: 0.5) else {return}
        
        let imageName = UUID().uuidString
        
        let imageReference = Storage.storage().reference().child("MyPhoto").child(imageName)
        
        
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            imageReference.downloadURL { (url, error) in
                guard let url = url, error == nil else {return}
                
                let urlString = url.absoluteString
                print("DOwnload URL", urlString)
                completion(urlString)
            }
        }
        
    }
    
    
    func saveClinicIntoFirebase() {
        
        if selectedClinic != nil {
            
            selectedClinic?.clinic.ref?.updateChildValues(["name": clinicName.text!,
                                                           "location": clinicLocation.text ?? "",
                                                           "city": clinicCity.text ?? ""])
            
            if imageIsChanged {
                DispatchQueue.main.async {
                    self.uploadPhoto { (url) in
                        self.selectedClinic?.clinic.ref?.updateChildValues(["image": url])
                    }
                }
            }
            
            
        } else {
            
            let user = Auth.auth().currentUser?.displayName
            let firClinic = FIRClinic.init(name: clinicName.text!,
                                           location: clinicLocation.text,
                                           city: clinicCity.text, image: nil,
                                           userId: user ?? "",
                                           longitude: longitude, latitude: latitude)
            MyRef.reference?.child(clinicName.text!).setValue(firClinic.convertToDictionary())
            
            if imageIsChanged {
                DispatchQueue.main.async {
                    self.uploadPhoto { (url) in
                        self.ref?.child(self.clinicName.text!).updateChildValues(["image": url])
                    }
                }
            }
            
        }
        
    }
    
    
    private func setupEditScreen() {
        if selectedClinic != nil {
            
            setupNavigationBar()

            clinicImage.image = selectedClinic?.image
            clinicImage.contentMode = .scaleAspectFill
            clinicName.text = selectedClinic?.clinic.name
            clinicLocation.text = selectedClinic?.clinic.location
            clinicCity.text = selectedClinic?.clinic.city
           
        } else { showAddress.isHidden = true }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = nil
        title = selectedClinic?.clinic.name
        
        saveButton.isEnabled = true
    }
    

    
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }




}


// MARK: Text field delegate
extension DetailViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию на Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if clinicName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: Work with image
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        clinicImage.image = info[.editedImage] as? UIImage
        clinicImage.contentMode = .scaleAspectFill
        clinicImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

extension DetailViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?, _ city: String?, _ longitude: String?, _ latitude: String?) {
        clinicLocation.text = address
        clinicCity.text = city
        self.longitude = longitude
        self.latitude = latitude
    }
    

}
