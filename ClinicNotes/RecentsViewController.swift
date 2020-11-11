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
  
    var notesArray = Array<Note>()

    var fetchingMore = false
    var endReached = false


    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {


    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        setTableViewBackgroundGradient()
        tableView.refreshControl = myRefreshControl
        ref = Database.database().reference(withPath: "Notes")
     
       
    }

    @objc private func refresh(sender: UIRefreshControl) {

        sender.endRefreshing()

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

        return notesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomRecentsCell

        cell.commentLabel.text = notesArray[indexPath.row].comment
        cell.clinicNameLabel.text = notesArray[indexPath.row].clinic
        cell.deviceLabel.text = notesArray[indexPath.row].device
        let user = Auth.auth().currentUser?.displayName == notesArray[indexPath.row].user ? NSLocalizedString("You", comment: "") : notesArray[indexPath.row].user
        cell.userDateLabel.text = "\(NSLocalizedString("Added", comment: "")): \(user), \(notesArray[indexPath.row].dateUpdated)"
        

        
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = NSLocalizedString("No any notes yet", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return notesArray.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notesArray[indexPath.row]
        performSegue(withIdentifier: "showRecent", sender: selectedNote)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let selectedNote = notesArray[indexPath.row]
            if Auth.auth().currentUser?.displayName == selectedNote.user {
                notesArray.remove(at: indexPath.row)
                selectedNote.ref?.removeValue()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                self.showAlert(title: NSLocalizedString("Delete denied!", comment: ""), message: NSLocalizedString("You not created this Note!", comment: ""))
            
            }
            
        }

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }

}
