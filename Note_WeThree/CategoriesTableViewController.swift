//
//  ViewController.swift
//  Note_WeThree
//
//  Created by Chaitanya Sanoriya on 15/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let headerView = StrechyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250))

        headerView.labelView.text = "Folders"
        self.tableView.tableHeaderView = headerView
    }


}

