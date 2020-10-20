//
//  RecentsViewController.swift
//  ClinicNotes
//
//  Created by Blezin on 20.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase

class RecentsViewController: UITableViewController {
    
    var ref: DatabaseReference?
    
    let format = DateFormatter()
    var notes = Array<Note>()
    
    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFirebaseData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        setTableViewBackgroundGradient()
        tableView.refreshControl = myRefreshControl
        ref = Database.database().reference(withPath: "Cliniks")
     
        
    }

    @objc private func refresh(sender: UIRefreshControl) {
        fetchFirebaseData()
        sender.endRefreshing()

    }
    

    
    
    private func fetchFirebaseData() {
        ref?.observeSingleEvent(of: .value) { snapshot in
            
            var _notes = Array<Note>()
            let notes = snapshot.children.allObjects
            
            for i in notes {
                let a = i as! DataSnapshot
                
                let devices = a.childSnapshot(forPath: "Devices")
                let note = devices.children
                
                for b in note {
                    let c = b as! DataSnapshot
                    let notes = c.childSnapshot(forPath: "Notes")
                    let comment = notes.children
                    
                    for note in comment {
                        let noteSnapshot = note as! DataSnapshot
                        let note = Note(snapshot: noteSnapshot)
                        _notes.append(note)
                    }
                    
                    self.notes = _notes.sorted(by: { (id1, id2) -> Bool in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm:ss"
                        if let dateA = dateFormatter.date(from: id1.dateUpdated),
                            let dateB = dateFormatter.date(from: id2.dateUpdated) {
                            return dateA.compare(dateB) == .orderedDescending
                        }
                        return false
                    })
                    self.tableView.reloadData()
                    
                    
                }
            }
        }

    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRecent" {
            let noteVC = segue.destination as? NewNotesViewController
            noteVC?.incomeSegue = segue.identifier!
            noteVC?.note = sender as? Note
            
        }
    }
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomRecentsCell

        cell.commentLabel.text = notes[indexPath.row].comment
        cell.clinicNameLabel.text = notes[indexPath.row].clinic
        cell.deviceLabel.text = notes[indexPath.row].device
        let user = Auth.auth().currentUser?.displayName == notes[indexPath.row].user ? "You" : notes[indexPath.row].user
        cell.userDateLabel.text = "Added: \(user), \(notes[indexPath.row].dateUpdated)"

        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        performSegue(withIdentifier: "showRecent", sender: selectedNote)
    }
    

}
