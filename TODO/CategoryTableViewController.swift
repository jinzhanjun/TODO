//
//  CategoryTableViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/9.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class CategoryTableViewController: UITableViewController {

    var textField = UITextField()
    lazy var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
//        view.backgroundColor = UIColor.white
//        view.layer.shadowOpacity = 0.8
//        view.layer.shadowColor = UIColor.black.cgColo
//        view.layer.shadowOffset = CGSize(width: -50, height: 50)
        loadCategories()
//        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "1D9BF6") else { fatalError()}
        navigationController?.navigationBar.backgroundColor = originalColor
//        navigationController?.navigationBar.tintColor = FlatOrange()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: originalColor]
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "添加类别", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "添加", style: .default) { (AlertAction) in
            if self.textField.text?.count != 0 {
                let category = Category(context: self.context)
                category.name = self.textField.text
                category.backGroundColor = UIColor.randomFlat().hexValue()
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
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].backGroundColor ?? "1D9BF6")
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "GoToItems", sender: self)
        performSegue(withIdentifier: "Test", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Test",
            let destinationVC = segue.destination as? ToDoItemListViewController,
            let indexPath = tableView.indexPathForSelectedRow
            {
                destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
}

extension CategoryTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "删除") { (action, indexPath) in
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
        }
        
        
        deleteAction.image = UIImage(named: "Trash-circle")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
}
