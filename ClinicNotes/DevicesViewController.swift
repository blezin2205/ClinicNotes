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
    
    var selectedClinic: FIRClinic?

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
                format.dateFormat = "dd,MM,yyyy,HH:mm:ss"
                let deviceRef = self.selectedClinic?.ref?.child("Devices").child((nameofDevice.lowercased() + format.string(from: date)))
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
        let user = devices[indexPath.row].createdBy == currentUser ? "You" : devices[indexPath.row].createdBy
        cell.createdLabel.text = "Created: \(user); \(devices[indexPath.row].dateCreated)"
        let _updateUser = devices[indexPath.row].updatedBy == currentUser ? "You" : devices[indexPath.row].updatedBy
        guard let updateUser = _updateUser, let updateDate = devices[indexPath.row].dateUpdated else {return cell}
        cell.updatedLabel.text = "Last update: \(updateUser); \(updateDate)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender = devices[indexPath.row]
        
        performSegue(withIdentifier: "showDevice", sender: sender)
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           cell.backgroundColor = .clear
       }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let selectedDevice = devices[indexPath.row]
            if currentUser == selectedDevice.createdBy {
                selectedDevice.ref?.removeValue()
            } else {
                self.showAlert(title: "Delete denied!", message: "You not created this Device!")
            
            }
            
        }

    }
   
    
 


}
