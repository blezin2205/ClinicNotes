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

        if incomeSegue == "showNote" {
            noteTextField.text = note?.comment
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
            navigationItem.title = serialNumber
            print(index)
            print(note?.type)
            
            
        }
      
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
