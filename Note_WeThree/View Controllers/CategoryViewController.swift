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
    
    var appContext: NSManagedObjectContext!
    var categoryCount: Int = 0
    var categories: [String] = [String]()
    var notesCount: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        context for core data operations
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appContext = appDelegate.persistentContainer.viewContext
        
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        loadCategories()
    }
    
    func loadCategories() {
////        gets the category count
//        self.categoryCount = NotesHelper.getInstance().getNumberOfCategories()
////        sets the value for categories array
//        for i in 0...categoryCount {
//            let category = NotesHelper.getInstance().getCategory(at: i)
//            self.categories.append(category)
////            sets the number of notes for each category
//            let count = NotesHelper.getInstance().getNumberOfNotes(inCategory: i)
//            self.notesCount.append(count)
//        }
    }
    
    
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        return cell
    }
}

