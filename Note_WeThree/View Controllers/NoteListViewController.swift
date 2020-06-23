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
    
//    value of category to load nots for
    var indexValue: Int?
    
//    selection for which segue to be performed - move notes view / note view
    var segueForMoveView: Bool = false
    
//    context for core data operation
    var notesContext: NSManagedObjectContext!
    
//    for selection of multiple rows
    var editingMode: Bool = false
    
//    for sending the value to next screen
    var noteCellTapped: Int?
    
//    stores the list of selected notes to move
    var selectedNotesForMove: [Int] = [Int]()
    
//    for getting the category selected to move notes from move notes view
    var selectedCategoryToMove: Int?
    
    @IBOutlet weak var editButtonLabel: UIBarButtonItem!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noteListTableView: UITableView!
    @IBOutlet weak var moveButtonLabel: UIButton!
    @IBOutlet weak var noOfNotesLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        sets up context for data
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

//        hides the button on initialization
        self.moveButtonLabel.isHidden = true
//        sets the category name to header
        if let categoryIndex = self.indexValue {
            do {
                self.categoryLabel.text = try NotesHelper.getInstance().getCategory(at: categoryIndex)
            }
            catch {
                print(error)
            }
        }
        
    }
    
    
    
    
//    MARK: updates UI on every reload
    override func viewWillAppear(_ animated: Bool) {
        
//        sets the note count label
        if let categoryIndex = self.indexValue {
            do {
                self.noOfNotesLabel.text = try "\(NotesHelper.getInstance().getNumberOfNotes(forCategory: categoryIndex)) Note(s)"
            }
            catch {
                print(error)
            }
        }
        self.noteCellTapped = nil
        self.noteListTableView.reloadData()
        
    }
    
//    MARK: method to handle the set constraints for selection and edit button behavior
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if(self.editingMode) {
            self.noteListTableView.allowsMultipleSelectionDuringEditing = false
            self.noteListTableView.isEditing = false
            self.editButtonLabel.title = "Edit"
            self.selectedNotesForMove.removeAll()
            self.editingMode = false
            self.moveButtonLabel.isHidden = true
        }
        else {
            self.noteListTableView.isEditing = true
            self.noteListTableView.allowsMultipleSelectionDuringEditing = true
            self.editButtonLabel.title = "Cancel"
            self.editingMode = true
            self.moveButtonLabel.isHidden = false
        }
        
    }
    
    
    
    
//    MARK: handler for move button on multiple selection
    @IBAction func moveButtonPressed(_ sender: Any) {
        
        if(self.editingMode) {
            if(self.selectedNotesForMove.count > 0) {
                self.segueForMoveView = true
                performSegue(withIdentifier: "moveScreen", sender: self)
            }
        }
        
    }
    
    
    
    
//    MARK: performs segue to note view on button press
    @IBAction func newNoteButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "noteScreen", sender: self)
        
    }
    
    
    
    
//    MARK: method to be invoked after exit from modal view
    @IBAction func calledAfterFolderSelection(_ unwindSegue: UIStoryboardSegue) {
        if(selectedCategoryToMove != nil) {
            moveNotesToSelectedCategory()
        }
    
        self.editingMode = false
        self.segueForMoveView = false
        self.selectedCategoryToMove = nil
        self.selectedNotesForMove.removeAll()
        self.noteListTableView.reloadData()
    }
    
    
//    methods calls the core data methods for moving notes
    func moveNotesToSelectedCategory() {
        
        do {
            if let category = self.selectedCategoryToMove {
                try NotesHelper.getInstance().moveNotes(withIndexes: self.selectedNotesForMove, toCategory: category, context: self.notesContext)
            }
        }
        catch {
            print(error)
        }
        
    }
    
    
    
    
//    MARK: method to set values for next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        for case when segue to move notes view controller segue is to be performed
        if(self.segueForMoveView) {
            if let destinationView = segue.destination as? MoveNotesViewController {
                if let category = self.indexValue {
                    destinationView.categoryToLeave = category
                }
            }
        }
            
//            case when segue to open the note is to be performed
        else {
//            for old note
            if(self.noteCellTapped != nil) {
                if let destinationView = segue.destination as? NoteViewController {
                               if let note = self.noteCellTapped {
                                   destinationView.selectedNote = note
                               }
                    }
            }
//                for new note
            else {
                if let destinationView = segue.destination as? NoteViewController {
                              if let categoryIndex = self.indexValue {
                                  destinationView.forCategory = categoryIndex
                              }
                    }
            }
        }
        
    }
    
}




//MARK: implements the table view specific delegate methods
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
    
    
    
//    MARK: note deletion method by swipe
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
    
    
//    MARK: method to implement the seague to move note view on selecting an individual note by swipe
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let moveNote = UIContextualAction(style: .normal, title: "Move") { (action, view, completion) in
            
            self.selectedNotesForMove.append(indexPath.row)
            self.segueForMoveView = true
            self.performSegue(withIdentifier: "moveScreen", sender: nil)
            completion(true)
            
        }
        
        moveNote.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return UISwipeActionsConfiguration(actions: [moveNote])
        
    }
    
    
//    MARK: cell select or next segue selection method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        behavior of tapping when edit mode on
        if(self.editingMode) {
            self.selectedNotesForMove.removeAll()
            self.selectedNotesForMove.append(indexPath.row)
        }
//            behavior when edit mode off - seague to note view
        else {
            self.segueForMoveView = false
            self.noteCellTapped = indexPath.row
            performSegue(withIdentifier: "noteScreen", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(self.editingMode) {
            let index = self.selectedNotesForMove.firstIndex(of: indexPath.row)!
            self.selectedNotesForMove.remove(at: index)
        }
    }

}
