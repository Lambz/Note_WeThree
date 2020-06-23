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
        do {
            try NotesHelper.getInstance().loadNotes(withCategory: indexValue!, context: self.notesContext)
        }
        catch {
            print(error)
        }
//        sets up the delegate
        noteListTableView.delegate = self
        noteListTableView.dataSource = self

    }
    
    
}


extension NoteListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }


}
