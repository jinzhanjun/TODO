//
//  ViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/7.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    /// 定义内容字典
    let listDict = ["买面包", "敷面膜", "买手机", "买汽车"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 获取可重用cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItemCell", for: indexPath)
        // 设置cell的text
        cell.textLabel?.text = listDict[indexPath.row]
        // 返回cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 返回cell的数量
        return listDict.count
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

