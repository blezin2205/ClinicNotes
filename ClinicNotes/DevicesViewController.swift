//
//  DevicesViewController.swift
//  ClinicNotes
//
//  Created by Blezin on 04.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase

class DevicesViewController: UITableViewController {
    
    var selectedClinic: Clinic?

    let currentUser = Auth.auth().currentUser?.displayName
    var devices = Array<Device>()
    var searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        selectedClinic?.ref?.child("Devices").observe(.value, with: { (snapshot) in
            var _devices = Array<Device>()
            for item in snapshot.children {
                let device = Device(snapshot: item as! DataSnapshot)
                _devices.append(device)
            }
            self.devices = _devices
            self.tableView.reloadData()
            
        })
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        setTableViewBackgroundGradient()

        
    }

    
    
    @IBAction func SaveDevice(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addDevice" else {return}
        guard let source = unwindSegue.source as? NewDeviceViewController else { return }
        guard let currentUser = currentUser else {return}
        var serialNumber: String?
        if !source.serialNumberField.text!.isEmpty {
            serialNumber = source.serialNumberField.text
        }
            if let nameofDevice = source.label.text, !nameofDevice.isEmpty {
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy, HH:mm:ss"
            
            let device = Device(name: nameofDevice,
                                serialNumber: serialNumber,
                                dateUpdated: nil, updatedBy: nil,
                                createdBy: currentUser,
                                dateCreated: format.string(from: date))
                
            let deviceRef = self.selectedClinic?.ref?.child("Devices").childByAutoId()
            deviceRef?.setValue(device.convertToDictionary())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDevice" {
            
            let notecVC = segue.destination as? NotesViewController
            notecVC?.selectedDevice = sender as? Device
            notecVC?.selectedClinic = selectedClinic
            
        }
    }
    
    
    // MARK: - Table view data source

   


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomDeviceCell
        cell.deviceLabel.text = devices[indexPath.row].name
        cell.serialLabel.text = devices[indexPath.row].serialNumder
        let user = devices[indexPath.row].createdBy == currentUser ? NSLocalizedString("You", comment: "") : devices[indexPath.row].createdBy
        cell.createdLabel.text = "\(NSLocalizedString("Created by", comment: "")): \(user); \(devices[indexPath.row].dateCreated)"
        let _updateUser = devices[indexPath.row].updatedBy == currentUser ? "You" : devices[indexPath.row].updatedBy
        guard let updateUser = _updateUser, let updateDate = devices[indexPath.row].dateUpdated else {return cell}
        cell.updatedLabel.text = "\(NSLocalizedString("Last update", comment: "")): \(updateUser); \(updateDate)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender = devices[indexPath.row]
        
        performSegue(withIdentifier: "showDevice", sender: sender)
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           cell.backgroundColor = .clear
       }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "\(NSLocalizedString("Please add first device for", comment: "")) \(selectedClinic!.name)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return devices.count > 0 ? 0 : 250
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let selectedDevice = devices[indexPath.row]
            if currentUser == selectedDevice.createdBy {
                selectedDevice.ref?.removeValue()
            } else {
                self.showAlert(title: NSLocalizedString("Delete denied!", comment: ""), message: NSLocalizedString("You not created this Device!", comment: ""))
            
            }
            
        }

    }
   
    
 


}
