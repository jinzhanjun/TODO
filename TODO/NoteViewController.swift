//
//  NoteViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/18.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate {

    /// 记事本内容
    @objc var noteTitle: String?
    var block: ((String) -> Void)?
    // 设置字体大小
    var textFont = UIFont.systemFont(ofSize: 23)
    /// 设置字体属性
    var attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: 16]
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("滚动了")
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
        toolBar.setItems([addTextBtn, lineBtn], animated: true)
        view.addSubview(toolBar)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 获取光标位置
        let selectedRange = textView.selectedTextRange
        
        // 获取textView的text，并将其转换成可变属性文字
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        
        // 设置新插入数值的属性
        let newStr = NSMutableAttributedString(string: text)
        newStr.addAttributes(attrs, range: NSMakeRange(0, newStr.length))
        // 插入新的属性文本
        mutableStr.insert(newStr, at: textView.selectedRange.location)
        
        textView.attributedText = mutableStr
        
        
        let rect = textView.caretRect(for: selectedRange!.end)
        print(rect)
        if text == "\n" {
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
    // 下划线
    @objc private func lineText() {
        // 获取textView的文本，并且转换成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        // 获取当前光标位置
        let selectedRange = noteTextView.selectedRange
        
        // 插入文字
        let insertStr = NSAttributedString(string: "下划线文字")
        mutableStr.insert(insertStr, at: selectedRange.location)
        
        // 设置文字属性
        let attributes = [NSMutableAttributedString.Key.underlineStyle: 1]
        // 添加属性
        mutableStr.addAttributes(attributes, range: NSMakeRange(selectedRange.location, insertStr.length))
        
        // 更新文字
        noteTextView.attributedText = mutableStr
        // 更新光标位置
        let newRange = NSMakeRange(mutableStr.length, 0)
        noteTextView.selectedRange = newRange
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
    
    private func getSystem() {
        
    }
    
    // 插入图片
    private func insertPic(_ image: UIImage, mode: ImageAttachmentMode = .default) {
        
        // 获取noteTextView的所有文本，转成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        // 创建图片附件
        let imageAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imageAttachmentString: NSAttributedString
        imageAttachment.image = image
        //设置图片的显示方式
        if mode == .fitTextLine {
            // 与文字一样大小
            imageAttachment.bounds = CGRect(x: 0, y: -4, width: noteTextView.font!.lineHeight, height: noteTextView.font!.lineHeight)
        } else if mode == .fitTextView {
            // 撑满一行
            let imageWidth = noteTextView.frame.width - 10
            let imageHeight = image.size.height / image.size.width * imageWidth
            imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
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

    /// 图片附件的尺寸样式
    enum ImageAttachmentMode {
        case `default` // 默认（不改变大小）
        case fitTextLine // 使尺寸适应行高
        case fitTextView // 市尺寸使用noteTextView
    }
}
