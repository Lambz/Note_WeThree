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
    case InavlidIndexException
    case InvalidCategoryException
}

/// Notes Helper class, handles all the Note Data Operations. Implements Singleton Design Pattern. The class only interacts with database on the load up of App and at the resiging of app. While the app is in operationg all the Notes and Categories remain in the memory
class NotesHelper
{
    private var mNotes: [String:[Note]]
    private var mCategories: [String]
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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
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
            mCategories.append( result.value(forKey: "category") as! String)
        }
        
        // Loading Notes
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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
            let image_data = result.value(forKey: "image") as? NSData
            let lat = result.value(forKey: "lat") as? Double
            let long = result.value(forKey: "long") as? Double
            let message = result.value(forKey: "message") as? String
            let title = result.value(forKey: "title") as! String
            let image = image_data != nil ? UIImage(data: image_data! as Data) : nil
            let note = Note(title: title, message: message, lat: lat, long: long, image: image, date: date, categoryName: category, audioFileLocation: audio)
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
        // Saving Categories
        for category in mCategories
        {
            let new_category = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: context)
            new_category.setValue(category, forKey: "category")
            do
            {
                try context.save()
            }
            catch
            {
                print(error)
            }
        }
        
        // Saving Notes
        for category in mNotes.keys
        {
            for note in mNotes[category]!
            {
                let new_note = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
                new_note.setValue(note.mAudioFileLocation, forKey: "audio")
                new_note.setValue(note.mCategoryName, forKey: "category")
                new_note.setValue(note.mDate, forKey: "date")
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
    
    /// Function to get a category at  a particular index. Designed for TableView Controller
    /// - Parameter at: Index of the Category
    /// - Throws: Throws InavlidIndexException if the passed index is greated than Categories
    /// - Returns: Name of the category
    internal func getCategory(at: Int) throws -> String
    {
        if mCategories.count <= at
        {
            throw CustomExceptions.InavlidIndexException
        }
        return mCategories[at]
    }
    
    /// Adds Category into the Categories Array. The function also sorts the Category Names.
    /// - Parameter named: Name of the Category
    internal func addCategory(named: String)
    {
        mCategories.append(named)
        mCategories.sort()
    }
    
    /// Removes Category from the Categories Array and removes also removes associated with that folder
    /// - Parameter withIndex: Index of the Category to be removed
    internal func removeCategory(withIndex: Int)
    {
        let category = mCategories.remove(at: withIndex)
        if mNotes[category] != nil
        {
            mNotes.removeValue(forKey: category)
        }
    }
    
    /// Function to get Number of Categories
    /// - Returns: Number of Categories
    internal func getNumberOfCategories() -> Int
    {
        return mCategories.count
    }
    
    /// Function that returns a number of Notes in a particular Category
    /// - Parameter inCategory: Index of the Category
    /// - Throws: Throws InavlidIndexException if the passed index is greated than Categories
    /// - Returns: Number of Notes in a particular category
    internal func getNumberOfNotes(inCategory: Int) throws -> Int
    {
        if inCategory >= mCategories.count
        {
            throw CustomExceptions.InavlidIndexException
        }
        
        if mNotes[mCategories[inCategory]] != nil
        {
            return mNotes[mCategories[inCategory]]!.count
        }
        return 0
    }
    
    /// Function that returns a number of Notes in a particular Category
    /// - Parameter inCategory: Name of the Category
    /// - Throws: Throws InvalidCategoryException if the Category does not exist
    /// - Returns: Number of Notes in a particular category
    internal func getNumberOfNotes(inCategory: String) throws -> Int
    {
        if !mCategories.contains(inCategory)
        {
            throw CustomExceptions.InvalidCategoryException
        }
        
        if mNotes[inCategory] != nil
        {
            return mNotes[inCategory]!.count
        }
        return 0
    }
    
    /// Function to get a Note with a particular category and index
    /// - Parameters:
    ///   - withCategory: Category of the Note
    ///   - at: Index of the Note
    /// - Throws: Throws InvalidCategoryException if the Category does not exist
    /// - Returns: Note with a particular category and index
    internal func getNote(withCategory: String, at: Int) throws -> Note
    {
        if mNotes[withCategory] == nil
        {
            throw CustomExceptions.InvalidCategoryException
        }
        return mNotes[withCategory]![at]
    }
    
    /// Function to add Note in the Notes Array
    /// - Parameters:
    ///   - toCategory: Category Name
    ///   - note: Note Object
    internal func addNote(toCategory: String, note: Note)
    {
        if !mCategories.contains(toCategory)
        {
            mCategories.append(toCategory)
        }
        if mNotes[toCategory] != nil
        {
            mNotes[toCategory]!.append(note)
        }
        else
        {
            mNotes[toCategory] = [note]
        }
        sortNotes()
    }
    
    /// Function to sort the Notes on the basis of their title
    private func sortNotes()
    {
        for category in mNotes.keys
        {
            mNotes[category]!.sort { (note1, note2) -> Bool in
                if note1.mTitle < note2.mTitle
                {
                    return true
                }
                return false
            }
        }
    }
    
    /// Function to delete Note from Notes Array
    /// - Parameters:
    ///   - withCategory: Category Name
    ///   - at: Index of Note
    /// - Throws: Throws InvalidCategoryException if the Category does not exist
    internal func deleteNote(withCategory: String, at: Int) throws
    {
        if mNotes[withCategory] == nil
        {
            throw CustomExceptions.InvalidCategoryException
        }
        mNotes[withCategory]!.remove(at: at)
    }
    
    /// Function to delete Note from Notes Array
    /// - Parameter note: Note Object
    internal func deleteNote(note: Note)
    {
        for category in mNotes.keys
        {
            mNotes[category]!.removeAll { (note1) -> Bool in
                note1 === note
            }
        }
    }
    
    /// Function to move Note from One Category to Another
    /// - Parameters:
    ///   - fromCategory: Origin Category Name
    ///   - fromIndex: Index of the Category in the Origin Category
    ///   - toCategory: Category to where the Note is to be moved
    /// - Throws: Throws InvalidCategoryException if the Category does not exist
    internal func moveNote(fromCategory: String, fromIndex: Int, toCategory: String) throws
    {
        if mNotes[fromCategory] == nil
        {
            throw CustomExceptions.InvalidCategoryException
        }
        let note = mNotes[fromCategory]![fromIndex]
        deleteNote(note: note)
        note.mCategoryName = toCategory
        addNote(toCategory: toCategory, note: note)
    }
    
    /// Function to move Note from One Category to Another
    /// - Parameters:
    ///   - fromCategory: Origin Category Name
    ///   - toCategory: Category to where the Note is to be moved
    ///   - note: Note Object to be moved
    /// - Throws: Throws InvalidCategoryException if the Category does not exist
    internal func moveNote(fromCategory: String, toCategory: String, note: Note) throws
    {
        if mNotes[fromCategory] == nil
        {
            throw CustomExceptions.InvalidCategoryException
        }
        deleteNote(note: note)
        note.mCategoryName = toCategory
        addNote(toCategory: toCategory, note: note)
    }
    
    /// Function to move Note from One Category to Another
    /// - Parameters:
    ///   - fromCategory: Origin Category Name
    ///   - fromIndex: Index of the Category in the Origin Category
    ///   - toCategory: Index of the Category where Node needs to be moved
    /// - Throws: Throws InvalidCategoryException if the Category does not exist and throws InvalidIndexException if index of toCategory is greater than Categories Array
    internal func moveNote(fromCategory: String, fromIndex: Int, toCategory: Int) throws
    {
        if mNotes[fromCategory] == nil
        {
            throw CustomExceptions.InvalidCategoryException
        }
        if mCategories.count <= toCategory
        {
            throw CustomExceptions.InavlidIndexException
        }
        let note = mNotes[fromCategory]![fromIndex]
        deleteNote(note: note)
        note.mCategoryName = mCategories[toCategory]
        addNote(toCategory: mCategories[toCategory], note: note)
    }
    
    /// Function to move Note from One Category to Another
    /// - Parameters:
    ///   - fromCategory: Origin Category Name
    ///   - toCategory: Index of the Category where Node needs to be moved
    ///   - note: Note Object to be moved
    /// - Throws: Throws InvalidCategoryException if the Category does not exist and throws InvalidIndexException if index of toCategory is greater than Categories Array
    internal func moveNote(fromCategory: String, toCategory: Int, note: Note) throws
    {
        if mNotes[fromCategory] == nil
        {
            throw CustomExceptions.InvalidCategoryException
        }
        if mCategories.count <= toCategory
        {
            throw CustomExceptions.InavlidIndexException
        }
        deleteNote(note: note)
        note.mCategoryName = mCategories[toCategory]
        addNote(toCategory: mCategories[toCategory], note: note)
    }
}
