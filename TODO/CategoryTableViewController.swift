//
//  CategoryTableViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/9.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var textField = UITextField()
    lazy var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "添加类别", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "添加", style: .default) { (AlertAction) in
            if self.textField.text?.count != 0 {
                let category = Category(context: self.context)
                category.name = self.textField.text
                self.categoryArray.append(category)
                self.saveCategories()
            }
        }
        
        alert.addAction(action)
        alert.addTextField { (TextField) in
            self.textField = TextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func saveCategories() {
        try? context.save()
        tableView.reloadData()
    }
    
    func loadCategories() {
        let fetch: NSFetchRequest<Category> = Category.fetchRequest()
        try? categoryArray = context.fetch(fetch)
        tableView.reloadData()
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToItems",
            let destinationVC = segue.destination as? ToDoListViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
}
