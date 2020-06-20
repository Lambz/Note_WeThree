//
//  NotesHelper.swift
//  Note_WeThree
//
//  Created by Chaitanya Sanoriya on 19/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum CustomExceptions: Error
{
    case NoInstanceException
}

/// Notes Helper class, handles all the Note Data Operations. Implements Singleton Design Pattern. The class only interacts with database on the load up of App and at the resiging of app. While the app is in operationg all the Notes and Categories remain in the memory
class NotesHelper
{
    private var mNotes: [String:[Note]]
    private var mCategories: [Category]
    private static var mNumNotes: Int = 0
    private static var mInstance: NotesHelper?
    
    /// Parameterised Constructor to load all the Categories and Notes at the startup time
    private init()
    {
        self.mNotes = [:]
        self.mCategories = []
    }
    
    /// This Functions all the data from the databse into their respective arrays. It stores the Notes in a Dictionary and their category being there key. This method needs to be called when the app is loaded i.e. in the viewDidLoad function of the first ViewController
    /// - Parameter context: It is NSManagedObjectContext to be able to access Database
    internal func loadAllData(context: NSManagedObjectContext)
    {
        // Loading Categories
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
        var results: [NSManagedObject] = []
        do
        {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print(error)
        }
        for result in results
        {
            mCategories.append(Category(named: result.value(forKey: "category") as! String))
        }
        
        // Loading Notes
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
        results = []
        do
        {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print(error)
        }
        
        
        NotesHelper.mNumNotes = results.count
        for result in results
        {
            let audio = result.value(forKey: "category") as? String
            let category = result.value(forKey: "category") as! String
            let date = result.value(forKey: "date") as! Date
            let id = result.value(forKey: "id") as! Int
            let image_data = result.value(forKey: "image") as? NSData
            let lat = result.value(forKey: "lat") as? Double
            let long = result.value(forKey: "long") as? Double
            let message = result.value(forKey: "message") as? String
            let title = result.value(forKey: "title") as! String
            let image = image_data != nil ? UIImage(data: image_data! as Data) : nil
            let note = Note(id: id,title: title, message: message, lat: lat, long: long, image: image, date: date, categoryName: category, audioFileLocation: audio)
            if mNotes[category] != nil
            {
                
                mNotes[category]!.append(note)
            }
            else
            {
                mNotes[category] = [note]
            }
        }
    }

    
    /// This Function creates an instance of NotesHelper Class and returns it, implementing Singleton Design Pattern
    /// - Returns: Instance of NotesHelper
    internal static func getInstance() -> NotesHelper
    {
        if(mInstance == nil)
        {
            mInstance = NotesHelper()
        }
        return mInstance!
    }
    
    
    /// Function to return the number for Notes
    /// - Returns: number of Notes
    internal static func getNumberOfNotes() -> Int
    {
        return mNumNotes
    }
    
    /// Function to save all the Categories and Notes in the Database. This function needs to be called when the App is resigning
    /// - Parameter context: It is NSManagedObjectContext to be able to access Database
    internal func saveData(context: NSManagedObjectContext)
    {
        for category in mCategories
        {
            let new_category = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: context)
            new_category.setValue(category.mName, forKey: "category")
            do
            {
                try context.save()
            }
            catch
            {
                print(error)
            }
        }
        
        for category in mNotes.keys
        {
            for note in mNotes[category]!
            {
                let new_note = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
                new_note.setValue(note.mAudioFileLocation, forKey: "audio")
                new_note.setValue(note.mCategoryName, forKey: "category")
                new_note.setValue(note.mDate, forKey: "date")
                new_note.setValue(note.mID, forKey: "id")
                new_note.setValue(note.mImage?.pngData(), forKey: "image")
                new_note.setValue(note.mLat, forKey: "lat")
                new_note.setValue(note.mLong, forKey: "long")
                new_note.setValue(note.mMessage, forKey: "message")
                new_note.setValue(note.mTitle, forKey: "title")
                do
                {
                    try context.save()
                }
                catch
                {
                    print(error)
                }
            }
        }
    }
}
