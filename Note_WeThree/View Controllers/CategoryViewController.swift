//
//  CategoryViewController.swift
//  Note_WeThree
//
//  Created by Chetan on 2020-06-21.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    //variables for launch screen
    let titleImage = UIImageView(image: UIImage(named: "let'sNote.jpg")!)
    let noteImage = UIImageView(image: UIImage(named: "notebook-clip-art")!)
    let splashView = UIView()
    
    @IBOutlet weak var categoryTableView: UITableView!
//    context variable
    var appContext: NSManagedObjectContext!

    var categoryName: UITextField?
    var tappedCellIndex: Int?
    let mSearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        
        //color for splashView
        splashView.backgroundColor = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        // add subview for splash screen
        view.addSubview(splashView)
        
        // adding frame for splash view
        splashView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        noteImage.contentMode = .scaleAspectFit
        splashView.addSubview(noteImage)
        // adding frame for the image
        noteImage.frame = CGRect(x: splashView.frame.midX-50, y: splashView.frame.midY-50, width:100, height: 100)
        
        super.viewDidLoad()
//        context for core data operations
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appContext = appDelegate.persistentContainer.viewContext
        NotesHelper.getInstance().loadAllCategories(context: appContext)
        
//        sets up delegate for table view
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        self.title = "Categories"
        showSearchBar()
    }
    
    //MARK: SplashView(launchScreen)
    override func viewDidAppear(_ animated:Bool){
        //Adding delay
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2){
            self.scaleDownAnimation()
        }
    }
    func scaleDownAnimation(){
        UIView.animate(withDuration: 0.5, animations: {
            self.noteImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }){(success)in
            self.scaleUpAnimation()
        }
    }
    func scaleUpAnimation(){
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseIn, animations:{
            self.noteImage.transform = CGAffineTransform(scaleX: 5, y: 5)
            
        }){(success)in
            self.removeSplashScreen()
    
    }
        
        }
    //To remove splashView
    func removeSplashScreen(){
        splashView.removeFromSuperview()
        
    }
    
//    MARK:   alert for info button
    @IBAction func showInfo(_ sender: Any) {
        let msg = "This is a Note taking app, where you can write, organize and manage your ideas quickly and easily.\n\nAll you need to do is to click + button to add a category/note and add note to that.\n\nJust swipe the category/note to delete.\n\nEasy!"
        let alert = UIAlertController(title: "Welcome to Notes", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cool!", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    //    MARK: button to add category
    @IBAction func addCategory(_ sender: Any) {
        let alertForCategory = UIAlertController(title: "Lets' add a category", message: "", preferredStyle: .alert)
        alertForCategory.addTextField(configurationHandler: addCategoryName)
        alertForCategory.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if(self.categoryName?.text != nil) {
                NotesHelper.getInstance().addCategory(named: (self.categoryName?.text)!, context: self.appContext)
                self.categoryTableView.reloadData()
            }
        }))
        alertForCategory.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertForCategory, animated: true, completion: nil)
        
    }
    
    
//    handler for textfield for add category
    func addCategoryName(textField: UITextField) {
        self.categoryName = textField
        self.categoryName?.placeholder = "Enter Category Name"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.categoryTableView.reloadData()
        self.tappedCellIndex = nil
    }
    
    func showSearchBar() {
        
        mSearchController.obscuresBackgroundDuringPresentation = false
        mSearchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = mSearchController
        mSearchController.searchBar.delegate = self
        definesPresentationContext = true
    }
}




//  MARK: methods for table data handling
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return NotesHelper.getInstance().getNumberOfCategories()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        cell.setValues(index: indexPath.row)
        
        return cell
    }
    
    
//    MARK: swipe gesture for deletion of the categories
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            NotesHelper.getInstance().removeCategory(withIndex: indexPath.row, context: self.appContext)
            //        reloads data
            self.categoryTableView.reloadData()
            completion(true)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        delete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [delete])
        
    }
    
    
//    selects the row value and sends it to next view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tappedCellIndex = indexPath.row
        performSegue(withIdentifier: "noteListScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationView = segue.destination as? NoteListViewController {
            if let indexCell = self.tappedCellIndex {
                destinationView.indexValue = indexCell
            }
        }
    }
    
    
}

extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "category CONTAINS[cd] %@", searchBar.text!)
        NotesHelper.getInstance().loadAllCategories(context: appContext, withPredicate: predicate)
        categoryTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0
        {
            NotesHelper.getInstance().loadAllCategories(context: appContext)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            categoryTableView.reloadData()
        }
    }
}
