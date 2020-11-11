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
import FBSDKLoginKit
import GoogleSignIn

class ClinicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private let clinicNetworkService: ClinicNetworkServiceDelegate = ClinicNetworkService()
    private let searchController = UISearchController(searchResultsController: nil)
    private var clinics = Array<Clinic>()
    private var filteredClinics = Array<Clinic>()
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
        
        clinicNetworkService.getClinicSnapshot { (response) in
            self.clinics = response.clinics
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clinicNetworkService.ref?.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        }
    
    private func setupView() {
        tableView.register(UINib(nibName: "CustomClinicCell", bundle: nil), forCellReuseIdentifier: CustomClinicCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Clinic, Location or City", comment: "")
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = false
        }
    
    @IBAction func logOutButton(_ sender: Any) {
        clinicNetworkService.logOut(from: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "devices":
            let devicesVC = segue.destination as? DevicesViewController
            devicesVC?.selectedClinic = sender as? Clinic
        case "edit":
            let editClinicVC = segue.destination as? DetailViewController
            editClinicVC?.selectedClinic = sender as? (UIImage, Clinic)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomClinicCell.reuseId, for: indexPath) as! CustomClinicCell
        let clinic = isFiltering ? filteredClinics[indexPath.row] : clinics[indexPath.row]
        cell.set(clinic: clinic)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomClinicCell
        let cellImage = cell.imageOfClinic.image
        let selectedClinic = isFiltering ? filteredClinics[indexPath.row] as Clinic : clinics[indexPath.row] as Clinic
        performSegue(withIdentifier: "edit", sender: (cellImage, selectedClinic))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedClinic = isFiltering ? filteredClinics[indexPath.row] as Clinic : clinics[indexPath.row] as Clinic
        performSegue(withIdentifier: "devices", sender: selectedClinic)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = NSLocalizedString("Please add first one here", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return clinics.count > 0 ? 0 : 250
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let selectedClinic = isFiltering ? filteredClinics[indexPath.row] as Clinic : clinics[indexPath.row] as Clinic
            if Auth.auth().currentUser?.displayName == selectedClinic.userId {
                if isFiltering {
                    selectedClinic.ref?.removeValue()
                    filteredClinics.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    selectedClinic.ref?.removeValue()
                    clinics.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                self.showAlert(title: NSLocalizedString("Delete denied!", comment: ""), message: NSLocalizedString("You not created this Clinic!", comment: ""))
                
            }
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
