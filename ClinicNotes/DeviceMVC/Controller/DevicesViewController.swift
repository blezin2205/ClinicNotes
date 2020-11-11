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

    private let deviceNetworkService: DeviceNetworkServiceDelegate = DeviceNetworkService()
    let currentUser = Auth.auth().currentUser?.displayName
    var devices = Array<Device>()
    var searchController = UISearchController(searchResultsController: nil)
    var deviceRef: DatabaseReference?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        deviceNetworkService.getDeviceSnapshot(deviceRef: deviceRef) { (deviceResponse) in
            self.devices = deviceResponse.devices
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deviceRef?.removeAllObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        setTableViewBackgroundGradient()
        deviceRef = selectedClinic?.ref?.child("Devices")
    }

    
    
    @IBAction func SaveDevice(_ unwindSegue: UIStoryboardSegue) {
        deviceNetworkService.unwindSaveDeviceForSelectedClinic(currentUser: currentUser, unwindSegue: unwindSegue, deviceRef: deviceRef)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDevice" {
            
            let notecVC = segue.destination as? NotesViewController
            notecVC?.selectedDevice = sender as? Device
            notecVC?.selectedClinic = selectedClinic
            
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomDeviceCell
        let device = devices[indexPath.row]
        cell.set(currentUser: currentUser, device: device)

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
