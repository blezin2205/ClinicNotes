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

class ClinicViewController: UITableViewController {

    
    var clinics = Array<FIRClinic>()
    

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
        MyRef.reference = Database.database().reference(withPath: "Cliniks")
        checkLoggedIn()

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let editClinicVC = segue.destination as? DetailViewController
    //    let addNewDevicesVC = segue.destination as? DevicesTableViewController

        switch segue.identifier {
        case "addClinic":
            print("CASE ADDCLINIC")

            let navigation: UINavigationController = segue.destination as! UINavigationController
            guard let myNewClinicVC = navigation.viewControllers[0] as? DetailViewController else {return}


        case "devices":
            
            let devicesVC = segue.destination as? DevicesViewController
            print("devices segue")
            devicesVC?.selectedClinic = sender as? FIRClinic
        case "edit":
            print("CASE EDIT")
            editClinicVC?.selectedClinic = sender as? (UIImage, FIRClinic)
            
        default:
            break
        }

    }
    
    @IBAction func saveButton(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addClinic" else {return}
        guard let source = unwindSegue.source as? DetailViewController else { return }
        print("-----------------UnwindSegue------------------")
       // source.saveTask()
        source.saveClinicIntoFirebase()
        tableView.reloadData()

    }
    
    @IBAction func addClinicButton(_ sender: Any) {

        performSegue(withIdentifier: "addClinic", sender: self)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
       return clinics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
 
        let clinic = clinics[indexPath.row]
        
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

    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        let cellImage = cell.imageOfClinic.image
        let selectedClinic = clinics[indexPath.row] as FIRClinic
        performSegue(withIdentifier: "edit", sender: (cellImage, selectedClinic))
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedClinic = clinics[indexPath.row] as FIRClinic
       performSegue(withIdentifier: "devices", sender: selectedClinic)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let selectedClinic = clinics[indexPath.row] as FIRClinic
            selectedClinic.ref?.removeValue()
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
}


