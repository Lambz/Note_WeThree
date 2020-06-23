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
    
    var categoryToLeave: Int!
    var moveCategoryContext: NSManagedObjectContext!
    var selectedCategory: Int?
    
    @IBOutlet weak var categorySelectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initializes the context for data
        let moveCategoryDelegate = UIApplication.shared.delegate as! AppDelegate
        self.moveCategoryContext = moveCategoryDelegate.persistentContainer.viewContext
        NotesHelper.getInstance().loadAllCategories(context: moveCategoryContext)
        
//        
//        categorySelectionTableView.delegate = self
//        categorySelectionTableView.dataSource = self
    }
    
    
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

//
//extension MoveNotesViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectedCategory = indexPath.row
//        performSegue(withIdentifier: "goBackToNoteList", sender: self)
//    }
//}
