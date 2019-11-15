//
//  NoteViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/18.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 键盘出现/ 消失
    enum KeyBoardAppearence {
        case appear
        case disappear
    }
    /// textView的最大高度
    var textViewMaxHeight: CGFloat = 100 {
        didSet {
            textViewTextHeight = (textViewTextHeight > textViewMaxHeight) ? textViewMaxHeight : textViewTextHeight
        }
    }
    /// textView的文本高度
    var textViewTextHeight: CGFloat = 0
    
    /// 键盘高度
    var keyBoardHeight: CGFloat?
    
    /// 记事本内容
    @objc var noteTitle: String?
    var block: ((String) -> Void)?
    
    var alertController: UIAlertController?
    // 设置字体大小
    var textFont = UIFont.systemFont(ofSize: 23)
    /// 设置字体属性
    var attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: 16]
    
    
    /// 设置光标所在位置
    var selectedRange: NSRange?
    
    var range: NSRange = NSMakeRange(0, 1)
    /// 文本框视图
    let noteTextView: NoteTextView = NoteTextView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 44))
    /// 工具栏
    let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 44, width: UIScreen.main.bounds.width, height: 44))
    /// 记录键盘出现与消失
    var keyBoardAppearence = KeyBoardAppearence.disappear {
        didSet {
            switch keyBoardAppearence {
            case .appear:
                textViewMaxHeight = UIScreen.main.bounds.height - (keyBoardHeight ?? 0) - toolBar.bounds.height - 64
                print(textViewMaxHeight)
            case .disappear:
                textViewMaxHeight = UIScreen.main.bounds.height - toolBar.bounds.height - 64
                print(textViewMaxHeight)
            }
        }
    }

    /// 段落标志模型数组
    var lineStyleLabelModelArray: [lineStyleLabelModel]? = [] {
        didSet {
            guard let newArray = lineStyleLabelModelArray else {return}
            noteTextView.lineStyleLabelModelArray = newArray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // 记录光标位置
        selectedRange = textView.selectedRange
//        print(selectedRange)
        return true
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if noteTextView.isFirstResponder { noteTextView.resignFirstResponder() }
    }
    // 设置界面
    private func setupUI() {
        noteTextView.text = noteTitle
        noteTextView.isScrollEnabled = true
        noteTextView.delegate = self
        noteTextView.backgroundColor = UIColor.green
        noteTextView.contentInset.top = 10
        noteTextView.contentInset.bottom = 10
        // 避免闪烁问题
        noteTextView.layoutManager.allowsNonContiguousLayout = false
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
    
    // 文本变化后调用该方法
    func textViewDidChange(_ textView: UITextView) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = textView.textContainer.lineBreakMode
        
        let attributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let mulAttriString = NSMutableAttributedString(attributedString: textView.attributedText)
        //        let selectedRange = noteTextView.selectedRange
        mulAttriString.addAttributes(attributes, range: NSRange(location: 0, length: mulAttriString.length))
        
        var size = NoteTextView.getStringRect(with: textView.text, inTextView: textView, withAttributes: attributes)
        textViewTextHeight = size.height
        // 如果文本高度大于最大高度，textView高度为最大高度；反之为文本高度
        size.height = (size.height > textViewMaxHeight) ? textViewMaxHeight : size.height
        size.width = UIScreen.main.bounds.width
        //        print(size)
        textView.attributedText = mulAttriString
        // 更新textView的框架
        refreshViewFrame(withSize: size, toView: textView)
    }
    
    // 更新textView的框架
    private func refreshViewFrame(withSize size: CGSize, toView textView: UITextView) {
        var frame = textView.frame
        frame.size = size
        textView.frame = frame
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
    
    
    // 键盘出现消失动画
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else {return}
        
        // 键盘消失
        if frame.origin.y == UIScreen.main.bounds.size.height {
            keyBoardAppearence = .disappear
            UIView.animate(withDuration: duration){
                self.toolBar.transform = CGAffineTransform(translationX: 0, y: 0)
                // 更新textView的frame
                self.refreshViewFrame(withSize: CGSize(width: UIScreen.main.bounds.width, height: self.textViewTextHeight), toView: self.noteTextView)
            }
        }
        // 键盘出现
        else {
            // 获取键盘高度
            if keyBoardHeight == nil {keyBoardHeight = frame.height}
            keyBoardAppearence = .appear
            UIView.animate(withDuration: duration){
                self.toolBar.transform = CGAffineTransform(translationX: 0, y: -frame.size.height)
                // 更新textView的frame
                self.refreshViewFrame(withSize: CGSize(width: UIScreen.main.bounds.width, height: self.textViewTextHeight), toView: self.noteTextView)
            }
        }
    }
}

