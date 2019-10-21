//
//  NoteViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/18.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    var noteTitle: String?
    var block: ((String) -> Void)?
    @IBOutlet weak var noteText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteText.text = noteTitle ?? ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        block?(noteText.text)
    }
}
