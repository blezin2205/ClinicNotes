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
    var selectedClinic: FIRClinic?
    var notes = Array<Note>()
     let currentUser = Auth.auth().currentUser?.displayName
    
    
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
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        setTableViewBackgroundGradient()
    }

 
    
    @IBAction func saveNotes(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "showNote" else {return}
        guard let source = unwindSegue.source as? NewNotesViewController else { return }
        guard let currentUser = Auth.auth().currentUser?.displayName else {return}
        let type = source.segmentControl.titleForSegment(at: source.segmentControl.selectedSegmentIndex)
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy, HH:mm:ss"
        let dateUpdated = format.string(from: date)
        
        selectedDevice?.ref?.updateChildValues(["dateUpdated": dateUpdated,
                                                "updatedBy": currentUser])
        let note = Note(comment: source.noteTextField.text, type: type!, dateUpdated: dateUpdated, user: currentUser, device: selectedDevice!.name, clinic: selectedClinic!.name, serialNumber: selectedDevice?.serialNumder )
        format.dateFormat = "dd,MM,yyyy,HH:mm:ss"
        let deviceRef = self.selectedDevice?.ref?.child("Notes").child("note: \(format.string(from: date))")
        if source.incomeSegue == "showNote" {
            source.updateChildValues(dateUpdated: dateUpdated, currentUser: currentUser)
        } else {
            deviceRef?.setValue(note.convertToDictionary())
        }
        
        
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

        let user = notes[indexPath.row].user == currentUser ? "You" : notes[indexPath.row].user
        cell.textLabel?.text = notes[indexPath.row].comment
        cell.detailTextLabel?.text = "Last update: \(user); \(notes[indexPath.row].dateUpdated)"
        cell.detailTextLabel?.textColor = .placeholderText

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        performSegue(withIdentifier: "showNote", sender: selectedNote)
    }




}
