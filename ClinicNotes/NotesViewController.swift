//
//  NotesViewController.swift
//  ClinicNotes
//
//  Created by Blezin on 14.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase

class NotesViewController: UITableViewController {
    
    var selectedDevice: Device?
    var notes = Array<Note>()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        selectedDevice?.ref?.child("Notes").observe(.value, with: { (snapshot) in
            var _notes = Array<Note>()
            for item in snapshot.children {
                let note = Note(snapshot: item as! DataSnapshot)
                _notes.append(note)
            }
            self.notes = _notes
            self.tableView.reloadData()
        })

        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.title = selectedDevice?.name
    }

 
    
    @IBAction func saveNotes(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "saveNotes" else {return}
        guard let source = unwindSegue.source as? NewNotesViewController else { return }
        guard let currentUser = Auth.auth().currentUser?.displayName else {return}
        let type = source.segmentControl.titleForSegment(at: source.segmentControl.selectedSegmentIndex)
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let timestamp = "\(currentUser), \(format.string(from: date))"
        selectedDevice?.ref?.updateChildValues(["dateUpdated": timestamp])
        let note = Note(comment: source.noteTextField.text, type: type!, dateUpdated: timestamp, user: currentUser)
        format.dateFormat = "dd,MM,yyyy,HH:mm:ss"
        let deviceRef = self.selectedDevice?.ref?.child("Notes").child("note: \(format.string(from: date))")
        deviceRef?.setValue(note.convertToDictionary())
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard (segue.identifier != nil) else {return}
        switch segue.identifier {
        case "showNote":
            let noteVC = segue.destination as? NewNotesViewController
            noteVC?.incomeSegue = segue.identifier!
            noteVC?.note = sender as? Note
            noteVC?.serialNumber = selectedDevice?.serialNumder
        default:
            break
        }
    }
    
    // MARK: - Table view data source

 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = notes[indexPath.row].comment

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        performSegue(withIdentifier: "showNote", sender: selectedNote)
    }



}
