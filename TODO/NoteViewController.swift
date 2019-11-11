//
//  NoteViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/18.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// 记事本内容
    @objc var noteTitle: String?
    var block: ((String) -> Void)?
    
    var alertController: UIAlertController?
    // 设置字体大小
    var textFont = UIFont.systemFont(ofSize: 23)
    /// 设置字体属性
    var attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: 16]
    
    var range: NSRange = NSMakeRange(0, 1)
    /// 文本框视图
    let noteTextView: NoteTextView = NoteTextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44))
    /// 工具栏
    let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 44, width: UIScreen.main.bounds.width, height: 44))

    /// 段落标志模型数组
    var lineStyleLabelModelArray: [lineStyleLabelModel]? = [] {
        didSet {
            guard let newArray = lineStyleLabelModelArray else {return}
            noteTextView.lineStyleLabelModelArray = newArray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        setupUI()
        // 监听键盘发出的通知（通知的名称为：UIResponder.keyboardWillChangeFrameNotification）
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        block?(noteTextView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextView.becomeFirstResponder()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if noteTextView.isFirstResponder { noteTextView.resignFirstResponder() }
    }
    // 设置界面
    private func setupUI() {
        noteTextView.text = noteTitle
        view.addSubview(noteTextView)
        setupToolBar()
    }
    // 设置工具栏
    private func setupToolBar() {
        toolBar.backgroundColor = UIColor.red
        let addTextBtn = UIBarButtonItem(title: "添加", style: .plain, target: self, action: Selector(("addText")))
        let lineBtn = UIBarButtonItem(title: "下划线", style: .plain, target: self, action: Selector(("lineText")))
        let addPic = UIBarButtonItem(title: "图片", style: .plain, target: self, action: Selector(("showAlert")))
        toolBar.setItems([addTextBtn, lineBtn, addPic], animated: true)
        view.addSubview(toolBar)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        if text == "\n" {
//            //获取光标位置
//            let selectedRange = textView.selectedTextRange
//            let rect = textView.caretRect(for: selectedRange!.end)
//            // 添加段落标志
//            let lineLabelModel = lineStyleLabelModel(name: "H1", location: rect)
//            guard let modelArray = lineStyleLabelModelArray else {return true}
//            let tempArray = modelArray.contains { (model) -> Bool in
//                model.location == rect
//            }
//            !tempArray ? lineStyleLabelModelArray?.append(lineLabelModel) : ()
//        }
        return true
    }
    
    private func lineCountsOfString(string: String, constrainedToWidth: Double, font: UIFont) -> Double {
        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font: font])
        let lineCount = ceil(Double(textSize.width) / Double(constrainedToWidth))
        return lineCount
    }
    
    // alert
    @objc private func showAlert() {
        // 收回键盘，防止点击相册时键盘再次弹出
        noteTextView.resignFirstResponder()
        // 创建控制器
        alertController = UIAlertController()
        // 创建动作
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { (_) in
            self.alertController = nil
        }
        let addPicAction = UIAlertAction(title: "相册", style: .default) { [weak self](_) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self?.present(imagePicker, animated: true) {
                }
            } else {
                print("读取相册错误")
            }
        }
        
        let addCameraPicAction = UIAlertAction(title: "相机", style: .default) { [weak self] (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.sourceType = .camera
                cameraPicker.allowsEditing = true
                self?.present(cameraPicker, animated: true) { }
            }
        }
        
        alertController?.addAction(addCameraPicAction)
        alertController?.addAction(addPicAction)
        alertController?.addAction(cancelAction)
        
        present(alertController!, animated: true, completion: nil)
    }
    
    @objc private func addText() {
        noteTextView.addText()
    }
    
    // 从系统相册选择照片后执行
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        picker.dismiss(animated: true) {[weak self] in
            self?.noteTextView.insertPic(img, mode: .fitTextView)
        }
    }
    // 下划线
    @objc private func lineText() {
        noteTextView.typingAttributes = [NSMutableAttributedString.Key.underlineStyle: 1]
    }


    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else {return}
        if frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: duration) {
                self.noteTextView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.toolBar.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.noteTextView.transform = CGAffineTransform(translationX: 0, y: -frame.size.height)
                self.toolBar.transform = CGAffineTransform(translationX: 0, y: -frame.size.height)
            }
        }
    }
}

