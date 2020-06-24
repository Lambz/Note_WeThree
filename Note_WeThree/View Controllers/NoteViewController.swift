//
//  NoteViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-22.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class NoteViewController: UIViewController {
    
    var selectedNote: Int?
    var forCategory: Int?
    var noteViewContext: NSManagedObjectContext!
    var openedNote: Note!
    var latitude: Double?
    var longitude: Double?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteImage: UIImageView!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteTitle: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        sets up context for data
        let noteViewDelegate = UIApplication.shared.delegate as! AppDelegate
        self.noteViewContext = noteViewDelegate.persistentContainer.viewContext
        
        if(forCategory == nil) {
//            sets up note object if saved note opened
            if let noteIndex = self.selectedNote {
                do {
                    openedNote = try NotesHelper.getInstance().getNote(at: noteIndex)
                    showNoteOnLoad()
                }
                catch {
                    print(error)
                }
            }
        }
        
        
        
    }
    
    func showNoteOnLoad() {
        
        self.noteTitle.text = self.openedNote.mTitle
//        show date after formatting
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: self.openedNote.mDate)
        self.dateLabel.text = date
        
        if let message = self.openedNote.mMessage {
            self.noteText.text = message
        }
        if let image = self.openedNote.mImage {
            self.noteImage.image = image
        }
        if let lat = self.openedNote.mLat {
            self.latitude = lat
        }
        if let long = self.openedNote.mLong {
            self.longitude = long
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.selectedNote = nil
        self.forCategory = nil
        performSegue(withIdentifier: "backToNoteView", sender: self)
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if(self.forCategory != nil) {
            let title = self.noteTitle.text
            let msg = self.noteText.text
            let img = self.noteImage.image
            let date = Date()
            let category: String?
            if let categoryIndex = self.forCategory {
                do {
                    category = try NotesHelper.getInstance().getCategory(at: categoryIndex)
                }
                catch {
                    print(error)
                }
            }
            getCoordinates()
            
            let audiolocation: String?
            if(title != nil) {
                self.openedNote = Note(title: title!, message: msg, lat: self.latitude, long: self.longitude, image: img, date: date, categoryName: category!, audioFileLocation: audiolocation)
            }
            do {
                try NotesHelper.getInstance().addNote(note: self.openedNote, context: self.noteViewContext)
            }
            catch {
                print(error)
            }
        }
        
    }
    
    func getCoordinates() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
//        sets up value if new note
        if(self.forCategory != nil) {
            var currentLocation: CLLocation!

            if
               CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() ==  .authorizedAlways
            {
                currentLocation = locationManager.location
            }
            
            self.longitude = currentLocation.coordinate.longitude
            self.latitude = currentLocation.coordinate.latitude
            
        }
    }
    
    @IBAction func deleteNoteTapped(_ sender: Any) {
        
        if(self.selectedNote != nil) {
            if let noteIndex = self.selectedNote {
                do {
                    try NotesHelper.getInstance().deleteNote(at: noteIndex, context: self.noteViewContext)
                }
                catch {
                    print(error)
                }
            }
        }
        else {
            let msg = "Can't delete unsaved note!"
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.cancelButtonTapped(self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func recordAudio(_ sender: Any) {
    }
    @IBAction func cameraButtonTapped(_ sender: Any) {
    }
    
}


