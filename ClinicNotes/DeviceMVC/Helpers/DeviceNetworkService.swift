//
//  DeviceNetworkService.swift
//  ClinicNotes
//
//  Created by Blezin on 11.11.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import FirebaseDatabase


protocol DeviceNetworkServiceDelegate {
   
    func getDeviceSnapshot(deviceRef: DatabaseReference?, completion: @escaping(GetDeviceResponse) -> ())
    func unwindSaveDeviceForSelectedClinic(currentUser: String?, unwindSegue: UIStoryboardSegue, deviceRef: DatabaseReference?)
}


struct DeviceNetworkService: DeviceNetworkServiceDelegate {
    
    func unwindSaveDeviceForSelectedClinic(currentUser: String?, unwindSegue: UIStoryboardSegue, deviceRef: DatabaseReference?) {
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

                deviceRef?.childByAutoId().setValue(device.convertToDictionary())
        }
    }
    

    func getDeviceSnapshot(deviceRef: DatabaseReference?, completion: @escaping(GetDeviceResponse) -> ()) {
        
        FIRNetworkService.shared.getSnapshot(ref: deviceRef) { (snapshot) in
            let response =  GetDeviceResponse.init(snapshot: snapshot)
                completion(response)
          
        }
    }

}
