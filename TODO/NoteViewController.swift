//
//  NoteViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/18.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    var block: ((String) -> Void)?
    @IBOutlet weak var noteText: UITextView!
    
    @IBAction func saveNotePressed(_ sender: UIBarButtonItem) {
        if noteText.text.count != 0 {
            block?(noteText.text)
        }
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
