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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(indexValue)
    }
}
