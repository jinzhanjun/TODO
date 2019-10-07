//
//  ViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/7.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    /// 定义内容字典
    lazy var listArray = Array<ItemModel>()
    @IBAction func clearAllItems(_ sender: UIBarButtonItem) {
        removeAll()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var alertTextFeild = UITextField()
        
        /// 定义一个UIAlertController对象，用来显示添加新项目
        let alert = UIAlertController(title: "添加一个新项目", message: "", preferredStyle: .alert)
        
        /// 定义一个action，用来添加新项目到字典中
        let action = UIAlertAction(title: "添加", style: .default) { (action) in
            if alertTextFeild.text != "" {
                let newItem = ItemModel(text: alertTextFeild.text!, isDone: false)
                self.listArray.append(newItem)
                self.saveItems()
                self.tableView.reloadData()
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
        
        loadItems()
        if listArray.isEmpty {
            for i in 0..<20 {
                let model = ItemModel(text: "新项目\(i)", isDone: false)
                listArray.append(model)
            }
        }
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
        cell.textLabel?.text = listArray[indexPath.row].text
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
        // 保存模型
        saveItems()
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(listArray)
        if dataFilePath != nil {
            try? data?.write(to: dataFilePath!)
        }
    }
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decode = PropertyListDecoder()
            listArray = (try? decode.decode([ItemModel].self, from: data)) ?? []
        }
    }
    func removeAll() {
        listArray.removeAll()
        try? FileManager.default.removeItem(at: dataFilePath!)
        viewDidLoad()
    }
}

