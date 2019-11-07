//
//  ToDoItemListViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/19.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class ToDoItemListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var tableView: UITableView?
    var creatNewNoteBtn: UIButton?
    var search: UISearchBar?
    var noteCountLabel: UILabel?
    var noteCount: Int? {
        didSet {
            if noteCount == 0 {
                noteCountLabel?.text = "写点什么吧"
            }else {
                noteCountLabel?.text = "\(noteCount ?? 0)篇笔记"
            }
            noteCountLabel?.sizeToFit()
            noteCountLabel?.center.x = UIScreen.main.bounds.width / 2
        }
    }
    var selectedCategory: Category? {
        didSet {
            loadItems(predict: nil)
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
        cell.itemTextLabel.textColor = noteItemsArray[indexPath.row].textIsNil ? UIColor.darkGray : UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CreatNote", sender: indexPath)
    }
    
    func setupUI() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        creatNewNoteBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 64, y: UIScreen.main.bounds.height - 64, width: 44, height: 44))
        creatNewNoteBtn?.addTarget(self, action: #selector(creatNewNoteBtnPressed), for: .touchUpInside)
        search = UISearchBar(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 44))
        noteCountLabel = UILabel(frame: CGRect(x: 0, y: -50, width: 100, height: 44))
        noteCountLabel?.textColor = UIColor.darkGray
        tableView?.addSubview(noteCountLabel!)
        noteCount = noteItemsArray.count
        tableView?.contentInsetAdjustmentBehavior = .never
        tableView?.contentInset.top = 108
        search?.backgroundColor = UIColor.gray
        creatNewNoteBtn?.backgroundColor = UIColor.red
        view.addSubview(tableView!)
        view.addSubview(creatNewNoteBtn!)
        view.addSubview(search!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predict = NSPredicate(format: "title CONTAINS[C]%@", searchText)
        loadItems(predict: predict)
    }
    
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest(), predict: NSPredicate?) {
        let compredict = NSPredicate(format: "parentCategory.name CONTAINS[C]%@", selectedCategory!.name!)
        if predict != nil {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compredict, predict!])
            request.predicate = compoundPredicate
        } else {
            request.predicate = compredict
        }
        let sortDescription = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescription]
        try? noteItemsArray = context?.fetch(request) ?? []
        tableView?.reloadData()
    }
    
    func fetchNotes() {
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        try? noteItemsArray = (context?.fetch(request)) ?? []
    }
    
    @objc func creatNewNoteBtnPressed() {
        performSegue(withIdentifier: "CreatNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatNote" {
            guard let destinationVC = segue.destination as? NoteViewController else {return}
            
            if let sender = sender as? IndexPath {
                destinationVC.noteTitle = noteItemsArray[sender.row].textIsNil ? "" : noteItemsArray[sender.row].title
                destinationVC.block = {[weak self] (noteText) in
                    self?.noteItemsArray[sender.row].textIsNil = (noteText.count == 0) ? true : false
                    self?.noteItemsArray[sender.row].title = (self?.noteItemsArray[sender.row].textIsNil)! ? "思考一下，再写点什么" : noteText
                    DispatchQueue.main.async {
                        self?.saveNotes()
                    }
                }
            } else {
                destinationVC.block = {[weak self] (noteText) in
                    let item = Items(context: (self?.context)!)
                    item.title = noteText
                    item.isDone = false
                    item.parentCategory = self?.selectedCategory
                    item.textIsNil = (noteText.count == 0) ? true : false
                    item.title = item.textIsNil ? "思考一下，再写点什么" : noteText
                    self?.noteItemsArray.insert(item, at: 0)
                    self?.noteCount = self?.noteItemsArray.count
                    DispatchQueue.main.async {
                        self?.saveNotes()
                    }
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
