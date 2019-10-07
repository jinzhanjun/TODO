//
//  ViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/7.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    /// 定义内容字典
    var listArray = ["买面包", "敷面膜", "买手机", "买汽车"]
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var alertTextFeild = UITextField()
        
        /// 定义一个UIAlertController对象，用来显示添加新项目
        let alert = UIAlertController(title: "添加一个新项目", message: "", preferredStyle: .alert)
        
        /// 定义一个action，用来添加新项目到字典中
        let action = UIAlertAction(title: "添加", style: .default) { (action) in
            if alertTextFeild.text != "" {
                self.listArray.append(alertTextFeild.text!)
                self.defaults.set(self.listArray, forKey: "ListArray")
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
        if let items = defaults.array(forKey: "ListArray") as? [String] {
            listArray = items
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 获取可重用cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItemCell", for: indexPath)
        // 设置cell的text
        cell.textLabel?.text = listArray[indexPath.row]
        // 返回cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 返回cell的数量
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        // 取消点击
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
}

