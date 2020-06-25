//
//  CategoryCell.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-21.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import Foundation
class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryCount: UILabel!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    func setValues(index: Int) {
        
        do {
            let category = try NotesHelper.getInstance().getCategory(at: index)
            self.categoryName.text = category
            self.categoryCount.text = try "\(NotesHelper.getInstance().getNumberOfNotes(forCategory: index)) item(s)"
        }
        catch {
            print(error)
        }
        self.cellImage.image = UIImage(systemName: "folder")
    }
    
}
