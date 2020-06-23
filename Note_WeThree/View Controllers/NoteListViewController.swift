//
//  NoteListViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-22.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class NoteListViewController: UIViewController {
    
    var indexValue: Int = 0
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noteListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        sets up the delegate
        noteListTableView.delegate = self
        noteListTableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(indexValue)
    }
}


extension NoteListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
     
}
