//
//  ViewController.swift
//  Clinic Notes
//
//  Created by Blezin on 24.09.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import SDWebImage
import FBSDKLoginKit
import GoogleSignIn

class ClinicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let searchController = UISearchController(searchResultsController: nil)
    private var clinics = Array<FIRClinic>()
    private var filteredClinics = Array<FIRClinic>()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
   
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        MyRef.reference?.observe(.value) { (snapshot) in
                       var _clinics = Array<FIRClinic>()
                       for item in snapshot.children {
                           let clinic = FIRClinic(snapshot: item as! DataSnapshot)
                           _clinics.append(clinic)
                           
                       }
                       self.clinics = _clinics
                       self.tableView.reloadData()
                       
                   }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
        MyRef.reference?.removeAllObservers()
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        MyRef.reference = Database.database().reference(withPath: "Cliniks")
        checkLoggedIn()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Clinic, Location or City"
        searchController.hidesNavigationBarDuringPresentation = false
        
        
        navigationItem.searchController = searchController
        definesPresentationContext = false

    }
    
    
    
    @IBAction func logOutButton(_ sender: Any) {
        
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
                    self.showAlert(title: "Error", message: "Unable to LogOut!")
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
       
        case "devices":
            let devicesVC = segue.destination as? DevicesViewController
            devicesVC?.selectedClinic = sender as? FIRClinic
        case "edit":
             let editClinicVC = segue.destination as? DetailViewController
            editClinicVC?.selectedClinic = sender as? (UIImage, FIRClinic)
             editClinicVC?.incomeSegue = segue.identifier!
        default:
            break
        }

    }
    
    @IBAction func saveButton(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addClinic" else {return}
        guard let source = unwindSegue.source as? DetailViewController else { return }
        source.saveClinicIntoFirebase()
        tableView.reloadData()

    }
    
 

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredClinics.count
        }

       return clinics.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
 
        let clinic = isFiltering ? filteredClinics[indexPath.row] : clinics[indexPath.row]
        
        cell.accessoryType = .detailButton
        cell.nameLabel.text = clinic.name
        cell.locationLabel.text = clinic.location
        cell.cityLabel.text = clinic.city
        if let clinicImage = clinic.image {
            let url = URL(string: clinicImage)
            cell.imageOfClinic.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageOfClinic.sd_setImage(with: url, completed: nil)
         
        } else {
            cell.imageOfClinic.image = UIImage(named: "placeholder-image")
        }


        return cell

    }

    
     func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        let cellImage = cell.imageOfClinic.image
        let selectedClinic = isFiltering ? filteredClinics[indexPath.row] as FIRClinic : clinics[indexPath.row] as FIRClinic
        performSegue(withIdentifier: "edit", sender: (cellImage, selectedClinic))
    }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedClinic = isFiltering ? filteredClinics[indexPath.row] as FIRClinic : clinics[indexPath.row] as FIRClinic
       performSegue(withIdentifier: "devices", sender: selectedClinic)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let selectedClinic = isFiltering ? filteredClinics[indexPath.row] as FIRClinic : clinics[indexPath.row] as FIRClinic
            if Auth.auth().currentUser?.displayName == selectedClinic.userId {
                selectedClinic.ref?.removeValue()
            } else {
                self.showAlert(title: "Delete denied!", message: "You not created this Clinic!")
            
            }
            
        }

    }
    



}



extension ClinicViewController {
    
    private func checkLoggedIn() {
        
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        }

    }
    
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
            self.showAlert(title: "LogOut Error!", message: error.localizedDescription)
        }
    }
}


extension ClinicViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredClinics = clinics.filter({ (clinic) -> Bool in
            return clinic.name.lowercased().contains(searchText.lowercased()) ||
                   clinic.location!.lowercased().contains(searchText.lowercased()) ||
                clinic.city!.lowercased().contains(searchText.lowercased())

        })
    
        tableView.reloadData()
        
    }

}
