//
//  ViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/7.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var selectedCategory: Category? {
        didSet {
            loadItems(predicate: nil, sortDescription: nil)
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    /// 定义CoreData数据上下文
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    /// 使用CoreData获取数据
    lazy var listArray = Array<Items>()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var alertTextFeild = UITextField()
        
        /// 定义一个UIAlertController对象，用来显示添加新项目
        let alert = UIAlertController(title: "添加一个新项目", message: "", preferredStyle: .alert)
        
        /// 定义一个action，用来添加新项目到字典中
        let action = UIAlertAction(title: "添加", style: .default) { (action) in
            if alertTextFeild.text != "" {
                let newItem = Items(context: self.context)
                newItem.title = alertTextFeild.text
                newItem.isDone = false
                newItem.parentCategory = self.selectedCategory
                self.listArray.append(newItem)
                self.saveItems()
            }
        }
        
        alert.addTextField { (alertText) in
            alertText.placeholder = "请输入新项目名称"
            alertTextFeild = alertText
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        if listArray.isEmpty {
//            for i in 0..<20 {
//                let model = ItemModel(text: "新项目\(i)", isDone: false)
//                listArray.append(model)
//            }
//        }
//
//
//        if let items = defaults.array(forKey: "ListArray") as? [ItemModel] {
//            listArray = items
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 获取可重用cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItemCell", for: indexPath)
        // 设置cell的text
        cell.textLabel?.text = listArray[indexPath.row].title
        cell.accessoryType = listArray[indexPath.row].isDone ? .checkmark : .none
        // 返回cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 返回cell的数量
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消点击
        tableView.deselectRow(at: indexPath, animated: true)
        if listArray[indexPath.row].isDone {
            listArray[indexPath.row].isDone = false
        } else {
            listArray[indexPath.row].isDone = true
        }
//        context.delete(listArray[indexPath.row])
//        listArray.remove(at: indexPath.row)
        // 保存模型
        saveItems()
//        tableView.beginUpdates()
//        tableView.reloadRows(at: [indexPath], with: .fade)
//        tableView.endUpdates()
    }
    
    func saveItems() {
        
        try? context.save()
        tableView.reloadData()
//        let encoder = PropertyListEncoder()
//        let data = try? encoder.encode(listArray)
//        if dataFilePath != nil {
//            try? data?.write(to: dataFilePath!)
//        }
    }
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest(), predicate: NSPredicate?, sortDescription: NSSortDescriptor?) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let predicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
            request.predicate = compoundPredicate
        }else {
            request.predicate = categoryPredicate
        }
        
        if let sortDescription = sortDescription {
            request.sortDescriptors = [sortDescription]
        }
        try? listArray = context.fetch(request)
        tableView.reloadData()
//        context.fetch([request])
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decode = PropertyListDecoder()
//            listArray = (try? decode.decode([ItemModel].self, from: data)) ?? []
//        }
    }
//    func removeAll() {
//        listArray.removeAll()
//        try? FileManager.default.removeItem(at: dataFilePath!)
//        viewDidLoad()
//    }
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predict = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text!)
        /// 定义搜索结果排序方式
        let sortDescription = NSSortDescriptor(key: "title", ascending: true)
        loadItems(predicate: predict, sortDescription: sortDescription)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadItems(predicate: nil, sortDescription: nil)
        }
    }
}

