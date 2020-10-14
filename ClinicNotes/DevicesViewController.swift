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


        
    }

    
    
    @IBAction func SaveDevice(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addDevice" else {return}
        guard let source = unwindSegue.source as? NewDeviceViewController else { return }
        guard let currentUser = Auth.auth().currentUser?.displayName else {return}
        if let nameofDevice = source.label.text, !nameofDevice.isEmpty {
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let timestamp = "\(currentUser), \(format.string(from: date))"
            let device = Device(name: nameofDevice, serialNumber: source.serialNumberField.text, dateUpdated: timestamp)
            let deviceRef = self.selectedClinic?.ref?.child("Devices").child(nameofDevice.lowercased())
            deviceRef?.setValue(device.convertToDictionary())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDevice" {
            
            let notecVC = segue.destination as? NotesViewController
            notecVC?.selectedDevice = sender as? Device
            
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
        cell.dateLabel.text = "Last update: \(devices[indexPath.row].dateUpdated)" 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender = devices[indexPath.row]
        
        performSegue(withIdentifier: "showDevice", sender: sender)
    }
    
 


}
