//
//  CategoryViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-21.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryTableView: UITableView!
//    context variable
    var appContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        context for core data operations
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appContext = appDelegate.persistentContainer.viewContext
        NotesHelper.getInstance().loadAllCategories(context: appContext)
//        sets up delegate for table view
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
    }
    
    
    
//    MARK:   alert for info button
    @IBAction func showInfo(_ sender: Any) {
        let msg = "This is a Note taking app, where you can write, organize and manage your ideas quickly and easily.\n\nAll you need to do is to click + button to add a category/note and add note to that.\n\nJust swipe the category/note to delete.\n\nEasy!"
        let alert = UIAlertController(title: "Welcome to Notes", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cool!", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
//    MARK: button to add category
    @IBAction func addCategory(_ sender: Any) {
        
        
    }
}
//  for table data handling
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return NotesHelper.getInstance().getNumberOfCategories()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        
        cell.setValues(index: indexPath.row)
        
        return cell
    }
}

