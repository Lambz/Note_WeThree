//
//  MoveNotesViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-22.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class MoveNotesViewController: UIViewController {
    
//    to leave the move if same category selected
    var categoryToLeave: Int!
//    context for core data operations
    var moveCategoryContext: NSManagedObjectContext!
//    selected category stored for previous view
    var selectedCategory: Int?
    
    @IBOutlet weak var categorySelectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initializes the context for data
        let moveCategoryDelegate = UIApplication.shared.delegate as! AppDelegate
        self.moveCategoryContext = moveCategoryDelegate.persistentContainer.viewContext
        NotesHelper.getInstance().loadAllCategories(context: moveCategoryContext)
        
        categorySelectionTableView.delegate = self
        categorySelectionTableView.dataSource = self
    }
    
    
//    MARK: method implements cancel button tap
    @IBAction func cancelButtonPressed(_ sender: Any) {
//        sets value to nil
        self.selectedCategory = nil
        performSegue(withIdentifier: "goBackToNoteList", sender: self)
        
    }
    
    
    
//    updates the values in note list view if category selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(selectedCategory != nil) {
            if let destinationView = segue.destination as?  NoteListViewController {
                if let category = self.selectedCategory {
                    destinationView.selectedCategoryToMove = category
                }
            }
        }
        
    }
}



// MARK: to handle table delegate functions
extension MoveNotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return NotesHelper.getInstance().getNumberOfCategories()
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = categorySelectionTableView.dequeueReusableCell(withIdentifier: "categoryCell")
        
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        }
        do
        {
            cell?.textLabel?.text = try NotesHelper.getInstance().getCategory(at: indexPath.row)
        }
        catch
        {
            print(error)
        }
        cell?.imageView?.image = UIImage(systemName: "folder")
        cell?.imageView?.tintColor = UIColor(displayP3Red: 219/255, green: 174/255, blue: 60/255, alpha: 1.0)
        return cell!
    }

    
    
//    MARK: handles the cell tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        leaves the updatation if same category selected
        if(indexPath.row != categoryToLeave) {
            self.selectedCategory = indexPath.row
        }
        performSegue(withIdentifier: "goBackToNoteList", sender: self)
        
    }
    
}
