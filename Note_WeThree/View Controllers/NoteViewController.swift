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
import AVFoundation

class NoteViewController: UIViewController {
    
//    variables to distinguish between weather old note opened or new note
    var selectedNote: Int?
    var forCategory: Int?
//    index variable to store the new note
    var tempNoteIndex: Int?
    
    var noteViewContext: NSManagedObjectContext!
    var openedNote: Note!
    var latitude: Double?
    var longitude: Double?
    
    
//    for audio recording and playing
    var didRecord = false
    var isRecording = false
    var recordingIsAvailable = false
    var voiceRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var fileName = ""
    
//    variables for location manager
    let locationManager = CLLocationManager()
    var didUpdatedLocation: (() -> ())?
    
//    image view variables
    var imagePickerController = UIImagePickerController()
    
    
    
    //    screen element outlets
    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var noteTextLabel: UITextField!
    @IBOutlet weak var noteImage: UIImageView!
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var locationLabel: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        sets up context for data
        let noteViewDelegate = UIApplication.shared.delegate as! AppDelegate
        self.noteViewContext = noteViewDelegate.persistentContainer.viewContext
        
        print(fileName.count)
        initalSetupOnViewLoad()
        
//        audio setup
        setUpAudioMethods()
        
//        map coordinates setup
        startLocationManager()
        
    }
    
    

//    MARK: UI event handler methods implemented
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.selectedNote = nil
        self.forCategory = nil
        performSegue(withIdentifier: "backToNoteView", sender: self)
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if(self.forCategory != nil) {
            saveNewNote()
        }
        else {
            saveOldNote()
        }
        
    }
    
    
    
    @IBAction func deleteNoteTapped(_ sender: Any) {
        
        if(self.selectedNote != nil) {
            if let noteIndex = self.selectedNote {
                do {
                    try NotesHelper.getInstance().deleteNote(at: noteIndex, context: self.noteViewContext)
                    self.cancelButtonTapped(self)
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
        
        if(recordingIsAvailable) {
            preparePlayer()
            audioPlayer.play()
            self.micButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
        else {
            if(!isRecording){
                self.micButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                voiceRecorder.record()
                isRecording = true
            }
            else{
                self.micButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                voiceRecorder.stop()
                isRecording = false
                recordingIsAvailable = true
            }
        }
        
    }
    
    @IBAction func viewLocation(_ sender: Any) {
        
        if(self.forCategory == nil) {
            if(self.openedNote.mLat != nil && self.openedNote.mLong != nil) {
                performSegue(withIdentifier: "mapScreen", sender: self)
            }
            
            else {
                let alert = UIAlertController(title: "Location cannot be displayed!", message: "The location when this note was taken is not available. It could be due to insufficient permissions or network error on your device.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Add image to note", message: "Choose a source to add image", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Camera Error!", message: "Can't access camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationView = segue.destination as? MapViewController {
            let location = CLLocation(latitude: CLLocationDegrees(exactly: self.latitude!)!, longitude: CLLocationDegrees(self.longitude!))
            destinationView.mDestination = location
        }
        
    }
    
}



// MARK: implements other delegate methods
extension NoteViewController {
//    MARK: sets up initial values on view load
    func initalSetupOnViewLoad() {
        
        do {
            self.noteText.isEditable = true
            self.noteText.isUserInteractionEnabled = true
            
            
            if(forCategory == nil) {
    //            sets up note object if saved note opened
                if let noteIndex = self.selectedNote {
                    openedNote = try NotesHelper.getInstance().getNote(at: noteIndex)
                    if(openedNote.mAudioFileLocation != nil) {
                        if(openedNote.mAudioFileLocation!.count < 2) {
                            self.micButton.isHidden = true
                        }
                        else {
                            if let audioFile = openedNote.mAudioFileLocation {
                                self.fileName = audioFile
                            }
                            self.micButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                            recordingIsAvailable = true
                        }
                    }
                    else {
                        self.micButton.isHidden = true
                    }
                    showNoteOnLoad()
                }
            }
            else {
                self.locationLabel.isHidden = true
                self.dateLabel.isHidden = true
                if let category = self.forCategory {
                    self.tempNoteIndex = try NotesHelper.getInstance().getNumberOfNotes(forCategory: category)
                    if let noteIndex = self.tempNoteIndex {
                        self.fileName = "note\(noteIndex).m4a"
                    }
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    
//    MARK: loads note incase old note opened
    func showNoteOnLoad() {
        
        self.noteTitle.text = self.openedNote.mTitle
//        show date after formatting
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: self.openedNote.mDate)
        self.dateLabel.text = date
        
        if let message = self.openedNote.mMessage {
//            self.noteTextLabel.text = message
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
    
    
    
    
// MARK: Note saving methods
//    checks nil title before saving
    func checkTitle(titleText: String?) -> Bool {
        if(titleText == nil || titleText!.count < 1) {
            let alert = UIAlertController(title: "Oops!", message: "Title can't be left blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
//    saves note if previously saved
    func saveOldNote() {
                        
        let title = self.noteTitle.text
        if(!checkTitle(titleText: title)) {
            return
        }
        else {
//            let msg = self.noteTextLabel.text
            let msg = self.noteText.text
            let img = self.noteImage.image
            self.openedNote.mTitle = title!
            self.openedNote.mMessage = msg
            self.openedNote.mImage = img
            
            if let noteIndex = selectedNote {
                do {
                   try NotesHelper.getInstance().updateNote(oldNote: noteIndex, newNote: openedNote, context: self.noteViewContext)
                    self.cancelButtonTapped(self)
                }
                catch {
                    print(error)
                    showSaveErrorAlert()
                }
            }
            self.stopLocationManager()
        }
        
    }
    
//    saves if new note
    func saveNewNote() {
        print("in func")
        do {
            let title = self.noteTitle.text
            let date = Date()
            var category: String!
            if let categoryIndex = self.forCategory {
                category = try NotesHelper.getInstance().getCategory(at: categoryIndex)
            }
            if(!checkTitle(titleText: title)) {
                return
            }
            else {
                print("conditions checked")
//                let msg = self.noteTextLabel.text
                let msg = self.noteText.text
                let img = self.noteImage.image
                var audiolocation: String?
                if didRecord {
                    audiolocation = fileName
                }
                
                self.openedNote = Note(title: title!, message: msg, lat: self.latitude, long: self.longitude, image: img, date: date, categoryName: category, audioFileLocation: audiolocation)
                
                try NotesHelper.getInstance().addNote(note: self.openedNote, context: self.noteViewContext)

                stopLocationManager()
                
                self.cancelButtonTapped(self)
            }
        }
        catch {
            print(error.localizedDescription)
            showSaveErrorAlert()
        }
                
    }
    
//    shows error if note can't be saved
    func showSaveErrorAlert() {
        let alert = UIAlertController(title: "Error!", message: "Error while saving note. Please try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}





//    MARK: audio record and play methods
extension NoteViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    
    func setUpAudioMethods() {
        self.startAudioSession()
        recordingSession = AVAudioSession.sharedInstance()
        try! recordingSession.setCategory(
            AVAudioSession.Category.playAndRecord)
    }
    
    func startAudioSession(){
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.setupRecorder()
                    } else {
                        print("permisssion for audio denied")
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func setupRecorder(){
        let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0 ] as [String : Any]
        
        do {
            voiceRecorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
            voiceRecorder.delegate = self
            voiceRecorder.prepareToRecord()
        }
        catch {
            print(error)
        }
        
    }
    
    func getCacheDirectory() -> URL {
        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return docsurl
    }
    
    func getFileURL() -> URL{
        let path  = getCacheDirectory()
        let filePath = path.appendingPathComponent("\(fileName)")
        return filePath
    }

    func preparePlayer(){
        do {
            audioPlayer =  try AVAudioPlayer(contentsOf: getFileURL())
            
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.micButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        self.didRecord = true
        let path  = getCacheDirectory()
        let filePath = path.appendingPathComponent("\(fileName)")
        let savePath = path.appendingPathComponent("\(fileName)")
        do {
            try FileManager.default.moveItem(at: filePath, to: savePath)
        }
        catch {
            print(error)
        }
    }
    
}


// MARK: delegate methods to handle user lcoation
extension NoteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(forCategory != nil) {
            longitude = locations.last?.coordinate.longitude
            latitude = locations.last?.coordinate.latitude
        }
        
    }
    
    func startLocationManager() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if(CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
}




// MARK: methods for handling image selection
extension NoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        noteImage.image = image
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
