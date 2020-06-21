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

/// Notes Helper class, handles all the Note Data Operations. Implements Singleton Design Pattern.
class NotesHelper
{
    private var mNotes: [Note]
    private var mCategories: [String]
    private static var mInstance: NotesHelper?
    
    /// Parameterised Constructor to load all the Categories and Notes at the startup time
    private init()
    {
        self.mNotes = []
        self.mCategories = []
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
    
    /// Function loads all the Categories in memory
    /// - Parameter context: It is NSManagedObjectContext to be able to access Database
    internal func loadAllCategories(context: NSManagedObjectContext)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        var results: [NSManagedObject] = []
        do
        {
            results = try context.fetch(fetchRequest)
        }
        catch
        {
            print(error)
        }
        for result in results
        {
            mCategories.append( result.value(forKey: "category") as! String)
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
    
    /// Adds Category into the Categories Array. The function also sorts the Category Names and Saves the Category in CoreData.
    /// - Parameter named: Name of the Category
    /// - Parameter context: NSManagedObjectContext object to be able to access Database
    internal func addCategory(named: String, context: NSManagedObjectContext)
    {
        mCategories.append(named)
        mCategories.sort()
        addCategoryInDatabase(named: named,context: context)
    }
    
    /// Adds Category in CoreData
    /// - Parameters:
    ///   - named: Name of the Category
    ///   - context: NSManagedObjectContext object to be able to access Database
    private func addCategoryInDatabase(named: String, context: NSManagedObjectContext)
    {
        let new_category_entity = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: context)
        new_category_entity.setValue(named, forKey: "category")
        do
        {
            try context.save()
        }
        catch
        {
            print(error)
        }
    }
    
    /// Removes Category from the Categories Array and removes also removes associated with that folder
    /// - Parameter withIndex: Index of the Category to be removed
    /// - Parameter context: NSManagedObjectContext object to be able to access Database
    internal func removeCategory(withIndex: Int, context: NSManagedObjectContext)
    {
        let category = mCategories.remove(at: withIndex)
        removeCategoryFromDatabase(withCategory: category, context: context)
        removeNotesFromDatabase(withCategory: category, context: context)
    }
    
    /// Removes a Category from CoreData
    /// - Parameters:
    ///   - withCategory: Category Name
    ///   - context: NSManagedObjectContext object to be able to access Database
    private func removeCategoryFromDatabase(withCategory: String, context: NSManagedObjectContext)
    {
        let fetch_request = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        fetch_request.predicate = NSPredicate(format: "category = %@", withCategory)
        do
        {
            let test = try context.fetch(fetch_request)
            for t in test
            {
                let object_to_delete = t as! NSManagedObject
               context.delete(object_to_delete)
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
        catch
        {
            print(error)
        }
    }
    
    /// Removes Notes from Database that is of one particular Category
    /// - Parameters:
    ///   - withCategory: Category Name
    ///   - context: NSManagedObjectContext object to be able to access Database
    private func removeNotesFromDatabase(withCategory: String, context: NSManagedObjectContext)
    {
        let fetch_request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetch_request.predicate = NSPredicate(format: "category = %@", withCategory)
        do
        {
            let test = try context.fetch(fetch_request)
            for t in test
            {
                let object_to_delete = t as! NSManagedObject
               context.delete(object_to_delete)
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
        catch
        {
            print(error)
        }
    }
    
    /// Function to get Number of Categories
    /// - Returns: Number of Categories
    internal func getNumberOfCategories() -> Int
    {
        return mCategories.count
    }
    
//    /// Function that returns a number of Notes in a particular Category
//    /// - Parameter inCategory: Index of the Category
//    /// - Throws: Throws InavlidIndexException if the passed index is greated than Categories
//    /// - Returns: Number of Notes in a particular category
//    internal func getNumberOfNotes(inCategory: Int) throws -> Int
//    {
//        if inCategory >= mCategories.count
//        {
//            throw CustomExceptions.InavlidIndexException
//        }
//
//        if mNotes[mCategories[inCategory]] != nil
//        {
//            return mNotes[mCategories[inCategory]]!.count
//        }
//        return 0
//    }
//
//    /// Function that returns a number of Notes in a particular Category
//    /// - Parameter inCategory: Name of the Category
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist
//    /// - Returns: Number of Notes in a particular category
//    internal func getNumberOfNotes(inCategory: String) throws -> Int
//    {
//        if !mCategories.contains(inCategory)
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//
//        if mNotes[inCategory] != nil
//        {
//            return mNotes[inCategory]!.count
//        }
//        return 0
//    }
//
//    /// Function to get a Note with a particular category and index
//    /// - Parameters:
//    ///   - withCategory: Category of the Note
//    ///   - at: Index of the Note
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist
//    /// - Returns: Note with a particular category and index
//    internal func getNote(withCategory: String, at: Int) throws -> Note
//    {
//        if mNotes[withCategory] == nil
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//        return mNotes[withCategory]![at]
//    }
//
//    /// Function to add Note in the Notes Array
//    /// - Parameters:
//    ///   - toCategory: Category Name
//    ///   - note: Note Object
//    internal func addNote(toCategory: String, note: Note)
//    {
//        if !mCategories.contains(toCategory)
//        {
//            mCategories.append(toCategory)
//        }
//        if mNotes[toCategory] != nil
//        {
//            mNotes[toCategory]!.append(note)
//        }
//        else
//        {
//            mNotes[toCategory] = [note]
//        }
//        sortNotes()
//    }
//
//    /// Function to sort the Notes on the basis of their title
//    private func sortNotes()
//    {
//        for category in mNotes.keys
//        {
//            mNotes[category]!.sort { (note1, note2) -> Bool in
//                if note1.mTitle < note2.mTitle
//                {
//                    return true
//                }
//                return false
//            }
//        }
//    }
//
//    /// Function to delete Note from Notes Array
//    /// - Parameters:
//    ///   - withCategory: Category Name
//    ///   - at: Index of Note
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist
//    internal func deleteNote(withCategory: String, at: Int) throws
//    {
//        if mNotes[withCategory] == nil
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//        mNotes[withCategory]!.remove(at: at)
//    }
//
//    /// Function to delete Note from Notes Array
//    /// - Parameter note: Note Object
//    internal func deleteNote(note: Note)
//    {
//        for category in mNotes.keys
//        {
//            mNotes[category]!.removeAll { (note1) -> Bool in
//                note1 === note
//            }
//        }
//    }
//
//    /// Function to move Note from One Category to Another
//    /// - Parameters:
//    ///   - fromCategory: Origin Category Name
//    ///   - fromIndex: Index of the Category in the Origin Category
//    ///   - toCategory: Category to where the Note is to be moved
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist
//    internal func moveNote(fromCategory: String, fromIndex: Int, toCategory: String) throws
//    {
//        if mNotes[fromCategory] == nil
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//        let note = mNotes[fromCategory]![fromIndex]
//        deleteNote(note: note)
//        note.mCategoryName = toCategory
//        addNote(toCategory: toCategory, note: note)
//    }
//
//    /// Function to move Note from One Category to Another
//    /// - Parameters:
//    ///   - fromCategory: Origin Category Name
//    ///   - toCategory: Category to where the Note is to be moved
//    ///   - note: Note Object to be moved
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist
//    internal func moveNote(fromCategory: String, toCategory: String, note: Note) throws
//    {
//        if mNotes[fromCategory] == nil
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//        deleteNote(note: note)
//        note.mCategoryName = toCategory
//        addNote(toCategory: toCategory, note: note)
//    }
//
//    /// Function to move Note from One Category to Another
//    /// - Parameters:
//    ///   - fromCategory: Origin Category Name
//    ///   - fromIndex: Index of the Category in the Origin Category
//    ///   - toCategory: Index of the Category where Node needs to be moved
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist and throws InvalidIndexException if index of toCategory is greater than Categories Array
//    internal func moveNote(fromCategory: String, fromIndex: Int, toCategory: Int) throws
//    {
//        if mNotes[fromCategory] == nil
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//        if mCategories.count <= toCategory
//        {
//            throw CustomExceptions.InavlidIndexException
//        }
//        let note = mNotes[fromCategory]![fromIndex]
//        deleteNote(note: note)
//        note.mCategoryName = mCategories[toCategory]
//        addNote(toCategory: mCategories[toCategory], note: note)
//    }
//
//    /// Function to move Note from One Category to Another
//    /// - Parameters:
//    ///   - fromCategory: Origin Category Name
//    ///   - toCategory: Index of the Category where Node needs to be moved
//    ///   - note: Note Object to be moved
//    /// - Throws: Throws InvalidCategoryException if the Category does not exist and throws InvalidIndexException if index of toCategory is greater than Categories Array
//    internal func moveNote(fromCategory: String, toCategory: Int, note: Note) throws
//    {
//        if mNotes[fromCategory] == nil
//        {
//            throw CustomExceptions.InvalidCategoryException
//        }
//        if mCategories.count <= toCategory
//        {
//            throw CustomExceptions.InavlidIndexException
//        }
//        deleteNote(note: note)
//        note.mCategoryName = mCategories[toCategory]
//        addNote(toCategory: mCategories[toCategory], note: note)
//    }
}
