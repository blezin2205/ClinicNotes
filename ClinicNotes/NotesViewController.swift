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
    var selectedClinic: Clinic?
    var notes = Array<Note>()
    let currentUser = Auth.auth().currentUser?.displayName
    var ref: DatabaseReference?
    
    
    override func viewWillAppear(_ animated: Bool) {


        let query = ref?.queryOrdered(byChild: "deviceRef").queryEqual(toValue: selectedDevice?.ref?.key)
        query?.observe(.value) { (datasnapshot) in
            var _notes = Array<Note>()
            for item in datasnapshot.children {
                let item = item as! DataSnapshot
                let note = Note(snapshot: item)
                _notes.append(note)
            }
            self.notes = _notes
            self.tableView.reloadData()
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "Notes")
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

        if source.incomeSegue == "showNote" {
            source.updateChildValues(dateUpdated: dateUpdated, currentUser: currentUser)
        } else {
            let note = Note(comment: source.noteTextField.text, type: type!, dateUpdated: dateUpdated, user: currentUser, device: selectedDevice!.name , clinic: selectedClinic!.name, serialNumber: selectedDevice?.serialNumder, deviceRef: (selectedDevice!.ref?.key)! )
            ref?.childByAutoId().setValue(note.convertToDictionary())
            
       
            
          
            
            
            
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

        let user = notes[indexPath.row].user == currentUser ? NSLocalizedString("You", comment: "") : notes[indexPath.row].user
        cell.textLabel?.text = notes[indexPath.row].comment
        cell.detailTextLabel?.text = "\(NSLocalizedString("Last update", comment: "")): \(user); \(notes[indexPath.row].dateUpdated)"
        cell.detailTextLabel?.textColor = .placeholderText

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "\(NSLocalizedString("Please add first note for", comment: "")) \(selectedDevice!.name)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return notes.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        performSegue(withIdentifier: "showNote", sender: selectedNote)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let selectedNote = notes[indexPath.row]
            if Auth.auth().currentUser?.displayName == selectedNote.user {
                selectedNote.ref?.removeValue()
            } else {
                self.showAlert(title: NSLocalizedString("Delete denied!", comment: ""), message: NSLocalizedString("You not created this Note!", comment: ""))
            
            }
            
        }

    }




}
