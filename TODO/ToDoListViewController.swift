//
//  ViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/7.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: UITableViewController {
    
    var creatNewNoteBtn: UIButton?
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    /// 定义CoreData数据上下文
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    /// 使用CoreData获取数据
    lazy var listArray = Array<Items>()
    
    var dragTexgLabel: UILabel?
    
    var selectedCategory: Category? {
        didSet {
            loadItems(predicate: nil, sortDescription: nil)
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
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
                
                self.dragTexgLabel?.text = "\(self.listArray.count)篇笔记"
                self.dragTexgLabel?.sizeToFit()
                self.dragTexgLabel?.center = CGPoint(x: self.view.center.x, y: -35)
            }
        }
        
        alert.addTextField { (alertText) in
            alertText.placeholder = "请输入新项目名称"
            alertTextFeild = alertText
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    

    /// 本类中所有UI控件全部加载完毕后，执行
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = 150
        tableView.estimatedRowHeight = 150
        setUpUI()
//        performSelector(onMainThread: #selector(setNewNoteWindow), with: nil, waitUntilDone: true)
        setNewNoteWindow()
//        setStatusBarStyle(.darkContent)
        
//        setStatusBarBackgroundColor(color: UIColor.white)
        /// 注册单元格
        tableView.register(UINib(nibName: "ToDoCell", bundle: nil), forCellReuseIdentifier: "ItemsCell")
    }
    
    @objc func setNewNoteWindow() {
        creatNewNoteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        creatNewNoteBtn?.backgroundColor = UIColor.red
        
        view.addSubview(creatNewNoteBtn!)
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
//        if let statusBarWindow: UIView = UIStatusBarManager
    }
    
    func setUpUI() {
        dragTexgLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 40))
        dragTexgLabel?.textColor = UIColor.darkGray
        if listArray.count == 0 {
            dragTexgLabel?.text = "写点什么吧"
        } else {
            dragTexgLabel?.text = "\(listArray.count)篇笔记"
        }
        dragTexgLabel?.sizeToFit()
        dragTexgLabel?.center = CGPoint(x: view.center.x, y: -35)
        tableView.addSubview(dragTexgLabel!)
    }
    
    /// 界面上所有可见部分都加载完毕后，执行
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else{ fatalError("导航栏不存在！")}
        
        let navBarColor = UIColor(hexString: (selectedCategory?.backGroundColor)!)
        navBar.backgroundColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor!, returnFlat: true)
        title = selectedCategory?.name
        searchBar.barTintColor = navBarColor
        
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor!, returnFlat: true)]
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 获取可重用cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell", for: indexPath) as! ToDoTableViewCell
//        cell.delegate = self
        if let color = UIColor(hexString: selectedCategory?.backGroundColor ?? "1D9BF6")?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(listArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        // 设置cell的text
        cell.itemTextLabel?.text = listArray[indexPath.row].title
//        cell.textLabel?.text = listArray[indexPath.row].title
//        cell.accessoryType = listArray[indexPath.row].isDone ? .checkmark : .none
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
        saveItems()
        
        performSegue(withIdentifier: "ShowNote", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNote" {
            if let destinationVC = segue.destination as? NoteViewController {
                
            }
        }
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            fatalError("\(error)")
        }
        try? context.save()
        tableView.reloadData()
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
        
        do {
            try listArray = context.fetch(request)
        } catch {
            fatalError("\(error)")
        }
        tableView.reloadData()
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
//        navigationController?.navigationBar.
    }
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

extension ToDoListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let action = SwipeAction(style: .destructive, title: "删除") { (action, indexPath) in
            
            self.context.delete(self.listArray[indexPath.row])
            self.listArray.remove(at: indexPath.row)
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//                self.tableView.reloadData()
//            }
        }
        
        action.image = UIImage(named: "Trash-circle")
        return [action]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        
        return options
    }
}
