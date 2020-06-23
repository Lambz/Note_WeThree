//
//  NoteCell.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-22.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var noteDescription: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteName: UILabel!
    
    func setValues(index: Int) {
        var note: Note?
        do {
            note =  try NotesHelper.getInstance().getNote(at: index)
        }
        catch {
            print(error)
        }
        
        self.noteName.text = note?.mTitle
        if let date = note?.mDate {
            self.dateLabel.text = "\(date)"
        }
        self.noteDescription.text = note?.mMessage
    }
}
