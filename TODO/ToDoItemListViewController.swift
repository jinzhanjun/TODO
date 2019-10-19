//
//  ToDoItemListViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/19.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData

class ToDoItemListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var tableView: UITableView?
    var creatNewNoteBtn: UIButton?
    var search: UISearchBar?
    var parentCategory: Category? {
        didSet {
            
        }
    }
    
    /// 懒加载笔记数组
    lazy var noteItemsArray = [Items]()
    /// 获取CoreData内容上下文
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var parentCategroy: Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView?.delegate = self
        tableView?.dataSource = self
        search?.delegate = self
        tableView?.estimatedRowHeight = 150
        tableView?.rowHeight = 150
        
        // 注册可重用cell
        tableView?.register(UINib(nibName: "ToDoCell", bundle: nil), forCellReuseIdentifier: "ItemsCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteItemsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell", for: indexPath) as! ToDoTableViewCell
        cell.itemTextLabel.text = noteItemsArray[indexPath.row].title
        return cell
    }
    
    func setupUI() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        creatNewNoteBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 64, y: UIScreen.main.bounds.height - 64, width: 44, height: 44))
        creatNewNoteBtn?.addTarget(self, action: #selector(creatNewNoteBtnPressed), for: .touchUpInside)
        search = UISearchBar(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 44))
        tableView?.contentInsetAdjustmentBehavior = .never
        tableView?.contentInset.top = 108
        search?.backgroundColor = UIColor.gray
        creatNewNoteBtn?.backgroundColor = UIColor.red
        view.addSubview(tableView!)
        view.addSubview(creatNewNoteBtn!)
        view.addSubview(search!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func fetchNotes() {
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[C]%@", )
        let fetch = try? context?.fetch(request)
    }
    
    @objc func creatNewNoteBtnPressed() {
        performSegue(withIdentifier: "CreatNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatNote" {
            guard let destinationVC = segue.destination as? NoteViewController else {return}
            
            destinationVC.block = {(noteText) in
                let item = Items(context: self.context!)
                item.title = noteText
                item.isDone = false
                item.parentCategory = self.parentCategroy
                self.noteItemsArray.append(item)
                DispatchQueue.main.async {
                    self.saveNotes()
                }
            }
        }
    }
    
    func saveNotes() {
        do {
            try context?.save()
        } catch {
            fatalError("\(error)")
        }
        
        tableView?.reloadData()
    }
}
