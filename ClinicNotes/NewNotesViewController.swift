//
//  NewNotesViewController.swift
//  ClinicNotes
//
//  Created by Blezin on 14.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase

class NewNotesViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var noteTextField: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var note: Note?
    var serialNumber: String?
    var incomeSegue = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        saveButton.isEnabled = false
        noteTextField.delegate = self
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        setupEditScreen()

    }
    
    private func setupEditScreen() {
        
        switch incomeSegue {
        case "showNote":
            noteTextField.text = note?.comment
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.leftBarButtonItem = nil
            title = note?.serialNumber ?? note?.device
            
            if Auth.auth().currentUser?.displayName == note?.user {
                noteTextField.isEditable = true
                segmentControl.isEnabled = true
            } else {
                noteTextField.isEditable = false
                segmentControl.isEnabled = false
                navigationItem.rightBarButtonItem = nil
            }
            let index = note?.type == "Service" ? 0 : 1
            segmentControl.selectedSegmentIndex = index
            
        case "showRecent":
            noteTextField.isEditable = false
            segmentControl.isEnabled = false
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
            noteTextField.text = note?.comment
            navigationController?.navigationBar.prefersLargeTitles = true
            title = note?.serialNumber ?? note?.device
            let index = note?.type == "Service" ? 0 : 1
            segmentControl.selectedSegmentIndex = index
            
        default:
            break
        }
    }

    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func updateChildValues(dateUpdated: String, currentUser: String) {
       
            note?.ref?.updateChildValues(["comment": noteTextField.text ?? "",
            "dateUpdated": dateUpdated,
            "type": segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)!,
            "user": currentUser])
        
    }

}

extension NewNotesViewController: UITextViewDelegate {
    

    func textViewDidChange(_ textView: UITextView) {
        
        if noteTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                  saveButton.isEnabled = true
              } else {
                  saveButton.isEnabled = false
              }
    }
    
    @objc private func segmentChanged() {
          
        if noteTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
       
      }
  
}
