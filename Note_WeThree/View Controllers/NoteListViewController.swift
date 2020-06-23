//
//  NoteListViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-22.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class NoteListViewController: UIViewController {
    
    var indexValue: Int?
    var notesContext: NSManagedObjectContext!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noteListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notesDelegate = UIApplication.shared.delegate as! AppDelegate
        self.notesContext = notesDelegate.persistentContainer.viewContext
        if(self.indexValue != nil) {
            if let categoryIndex = indexValue {
                do {
                    try NotesHelper.getInstance().loadNotes(withCategory: categoryIndex, context: self.notesContext)
                }
                catch {
                    print(error)
                }
            }
            
        }
        
//        sets up the delegate
        noteListTableView.delegate = self
        noteListTableView.dataSource = self

    }
    
    @IBAction func calledAfterFolderSelection(_ unwindSegue: UIStoryboardSegue) {
        NotesHelper.getInstance().moveNotes(withIndexes: NoteList, toCategory: selectedCategory, context: <#T##NSManagedObjectContext#>)
    }
    
    
}


extension NoteListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.indexValue != nil) {
            var rows: Int = 0
            if let categoryIndex = indexValue {
                do {
                    rows = try NotesHelper.getInstance().getNumberOfNotes(forCategory: categoryIndex)
                }
                catch {
                    print(error)
                }
            }
            return rows
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = noteListTableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        cell.setValues(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            do {
                try NotesHelper.getInstance().deleteNote(at: indexPath.row, context: self.notesContext)
            }
            catch {
                print(error)
            }
            //        reloads data
            self.noteListTableView.reloadData()
            completion(true)
        }

        delete.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        delete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let moveNote = UIContextualAction(style: .normal, title: "Move") { (action, view, completion) in
            self.performSegue(withIdentifier: "moveScreen", sender: nil)
        }
        
        moveNote.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return UISwipeActionsConfiguration(actions: [moveNote])
        
    }

}
