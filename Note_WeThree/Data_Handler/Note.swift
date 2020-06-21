//
//  Note.swift
//  Note_WeThree
//
//  Created by Chaitanya Sanoriya on 19/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import UIKit

/// Note Class for the Note
class Note
{
    internal var mTitle: String
    internal var mMessage: String?
    internal var mLat: Double?
    internal var mLong: Double?
    internal var mImage: UIImage?
    internal var mDate: Date
    internal var mCategoryName: String
    internal var mAudioFileLocation: String?
    
    /// Constructor with only necessary Parameters
    /// - Parameters:
    ///   - title: Title of the Note
    ///   - date: Date of creation of Note
    ///   - categoryName: Category Name of the Note
    init(title: String, date: Date, categoryName: String) {
        self.mTitle = title
        self.mDate = date
        self.mCategoryName = categoryName
    }
    
    /// Constructor consisting of all the variables except for ID. It is for when user makes a new Note
    /// - Parameters:
    ///   - title: Title of the Note
    ///   - message: Message of the Note
    ///   - lat: Latitude of when the Message was created
    ///   - long: Longitude of when the Message was created
    ///   - image: Image associated with the Note
    ///   - date: Date of creation of Note
    ///   - categoryName: Category Name of the Note
    ///   - audioFileLocation: Location of the audio file associated with the Note
    init(title: String, message: String?, lat: Double?, long: Double?, image: UIImage?, date: Date, categoryName: String, audioFileLocation: String?) {
        self.mTitle = title
        self.mMessage = message
        self.mLat = lat
        self.mLong = long
        self.mImage = image
        self.mDate = date
        self.mCategoryName = categoryName
        self.mAudioFileLocation = audioFileLocation
    }
    
//    /// Constructor consisting of all the variables. It is for when the Data is loaded from Core Data
//    /// - Parameters:
//    ///   - id: Id of the Note
//    ///   - title: Title of the Note
//    ///   - message: Message of the Note
//    ///   - lat: Latitude of when the Message was created
//    ///   - long: Longitude of when the Message was created
//    ///   - image: Image associated with the Note
//    ///   - date: Date of creation of Note
//    ///   - categoryName: Category Name of the Note
//    ///   - audioFileLocation: Location of the audio file associated with the Note
//    init(title: String, message: String?, lat: Double?, long: Double?, image: UIImage?, date: Date, categoryName: String, audioFileLocation: String?) {
//        self.mTitle = title
//        self.mMessage = message
//        self.mLat = lat
//        self.mLong = long
//        self.mImage = image
//        self.mDate = date
//        self.mCategoryName = categoryName
//        self.mAudioFileLocation = audioFileLocation
//    }
}
