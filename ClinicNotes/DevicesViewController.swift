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
    @IBAction func addButton(_ sender: Any) {
       
        
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            
            guard let textField = alertController.textFields?.first, textField.text != "" else { return }
            let task = Device(name: textField.text!, serialNumber: "123")
            let taskRef = self!.selectedClinic!.ref?.child("Devices").child(task.name.lowercased())
            taskRef?.setValue(task.convertToDictionary())
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = devices[indexPath.row].name
        return cell
    }


}
