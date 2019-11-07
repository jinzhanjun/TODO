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

        if text == "\n" {
            //获取光标位置
            let selectedRange = textView.selectedTextRange
            let rect = textView.caretRect(for: selectedRange!.end)
            // 添加段落标志
            let lineLabelModel = lineStyleLabelModel(name: "H1", location: rect)
            guard let modelArray = lineStyleLabelModelArray else {return true}
            let tempArray = modelArray.contains { (model) -> Bool in
                model.location == rect
            }
            !tempArray ? lineStyleLabelModelArray?.append(lineLabelModel) : ()
        }
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
        alertController?.addAction(addPicAction)
        alertController?.addAction(cancelAction)
        
        present(alertController!, animated: true, completion: nil)
    }
    
    // 从系统相册选择照片后执行
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        picker.dismiss(animated: true) {[weak self] in
            self?.insertPic(img, mode: .fitTextView)
        }
    }
    
    // 添加图片
    @objc private func addPic() {
        // 创建文本附件
//        var textAttachment = NSTextAttachment()
        
    }
    // 下划线
    @objc private func lineText() {
        noteTextView.typingAttributes = [NSMutableAttributedString.Key.underlineStyle: 1]
    }
    
    // 添加文字
    @objc private func addText() {
        // 获取textView的文本，并且转换成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        
        // 获取当前光标位置
        let selectedRange = noteTextView.selectedRange
        
        // 插入文字
        let attStr = NSAttributedString(string: "欢迎使用！")
        mutableStr.insert(attStr, at: selectedRange.location)
        
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 10
        let attributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.paragraphStyle: paraph]
        
        // 改变可变文本的字体属性
        mutableStr.addAttributes(attributes, range: NSMakeRange(0, mutableStr.length))
        
        // 再次记住新的光标位置
        let newSelectedRange = NSMakeRange(selectedRange.location + attStr.length, 0)
        
        // 重新给文本赋值
        noteTextView.attributedText = mutableStr
        
        // 恢复光标位置(上面代码执行之后，光标会移到最后面)
        noteTextView.selectedRange = newSelectedRange
    }
    // 插入图片
    private func insertPic(_ image: UIImage, mode: ImageAttachmentMode = .default) {
        
        // 获取noteTextView的所有文本，转成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        // 创建图片附件
        let imageAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imageAttachmentString: NSAttributedString
        
        //设置图片的显示方式
        if mode == .fitTextLine {
            let rect = CGRect(x: 0, y: -4, width: noteTextView.font!.lineHeight, height: noteTextView.font!.lineHeight)
            // 与文字一样大小
            imageAttachment.bounds = rect
            imageAttachment.image = imageResize(img: image, withSize: rect.size)
        } else if mode == .fitTextView {
            // 撑满一行
            let imageWidth = noteTextView.frame.width - 10 - 2 * noteTextView.lineFragmentPadding
            let imageHeight = image.size.height / image.size.width * imageWidth
            let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            imageAttachment.bounds = rect
            imageAttachment.image = imageResize(img: image, withSize: rect.size)
        }
        
        
        imageAttachmentString = NSAttributedString(attachment: imageAttachment)
        
        // 获得目前光标的位置
        let selectedRange = noteTextView.selectedRange
        // 插入文字
        mutableStr.insert(imageAttachmentString, at: selectedRange.location)
        
        // 设置可变字体的字体属性
        mutableStr.addAttributes([NSAttributedString.Key.font : textFont], range: NSMakeRange(0, mutableStr.length))
        // 再次记住光标位置
        let newSelectedRange = NSMakeRange(mutableStr.length + 1, 0)
        
        // 重新给文本赋值
        noteTextView.attributedText = mutableStr
        
        // 恢复光标位置（上面代码执行完毕之后，光标会移到最后面）
        noteTextView.selectedRange = newSelectedRange
        
        // 移动滚动条（确保光标在可视区域之内）
        noteTextView.scrollRangeToVisible(newSelectedRange)
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
    
    // 重画图像
    private func imageResize(img: UIImage, withSize: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint(), size: withSize)
        // 开启图形上下文
        UIGraphicsBeginImageContextWithOptions(withSize, true, 0)
        // 在上下文中画图像
        img.draw(in: rect)
        // 获取图像
        let resultImg = UIGraphicsGetImageFromCurrentImageContext()
        return resultImg
    }

    /// 图片附件的尺寸样式
    enum ImageAttachmentMode {
        case `default` // 默认（不改变大小）
        case fitTextLine // 使尺寸适应行高
        case fitTextView // 市尺寸使用noteTextView
    }
}

