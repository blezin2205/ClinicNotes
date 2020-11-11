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

class DetailViewController: UITableViewController, DetailClinicTextFieldDelegate {

    var selectedClinic: (image: UIImage, clinic: Clinic)?
    var imageIsChanged = false
    var longitude: String?
    var latitude: String?
    var incomeSegue = ""
    private let clinicNetworkService: ClinicNetworkServiceDelegate = ClinicNetworkService()

    @IBOutlet weak var clinicImage: UIImageView!
    @IBOutlet weak var clinicName: UITextField!
    @IBOutlet weak var clinicLocation: UITextField!
    @IBOutlet weak var clinicCity: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var showAddress: UIButton!
    @IBOutlet weak var getAddress: UIButton!
    @IBOutlet weak var createdByLabel: UILabel!
    
    var image: UIImage? { return clinicImage.image }
    var name: String { return clinicName.text! }
    var location: String? { return clinicLocation.text }
    var city: String? { return clinicCity.text }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        setTableViewBackgroundGradient()

        if incomeSegue == "edit" {
            createdByLabel.text = "\(NSLocalizedString("created by", comment: "")): \(selectedClinic!.clinic.userId )"
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
            self.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Location not exist or empty", comment: ""))
            return }
        
      if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
        UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(_latitude),\(_longitude)&directionsmode=driving")!)
      }
      else {
        self.showAlert(title: "GoogleMaps", message: "Can't use comgooglemaps://")
          
      }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let mapVC = segue.destination as? GooglemapVC else { return }
        mapVC.mapViewControllerDelegate = self
        mapVC.clinic = selectedClinic?.clinic
    }

    func saveClinicIntoFirebase() {
        clinicNetworkService.saveClinicIntoFirebase(imageIsChanged: imageIsChanged, selectedClinic: selectedClinic?.clinic, textField: self)
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
            
            let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: NSLocalizedString("Photo", comment: ""), style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }


    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          cell.backgroundColor = .clear
      }

}


// MARK: Text field delegate
extension DetailViewController: UITextFieldDelegate {

    
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
