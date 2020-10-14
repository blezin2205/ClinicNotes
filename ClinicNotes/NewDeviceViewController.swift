//
//  NewDeviceViewController.swift
//  ClinicNotes
//
//  Created by Blezin on 13.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase

class NewDeviceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var deviceField: UITextField!
    @IBOutlet weak var serialNumberField: UITextField!
    
    var picker: UIPickerView?
    
    let devices = [ "---","Micros 60 OT", "Micros ES60", "Yumizen H500", "Pentra 60", "Pentra C200", "Pentra 400" ]
    var selectedDevice: String?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "4153735.png")!)
        label.layer.borderColor = UIColor.systemGray.cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        picker = UIPickerView()
        picker?.delegate = self
        deviceField.inputView = picker
        deviceField.isHidden = true
        view.bringSubviewToFront(label)
        createToolBar()

    }
    
    @IBAction func button(_ sender: Any) {
        deviceField.becomeFirstResponder()
    }
    
    
    func createToolBar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        deviceField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        devices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        devices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        saveButton.isEnabled = true
        label.textColor = .black
        selectedDevice = devices[row]
        label.text = selectedDevice
        
    }
}
