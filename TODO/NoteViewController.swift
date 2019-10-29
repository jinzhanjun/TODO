//
//  NoteViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/18.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {

    var noteTitle: String?
    var block: ((String) -> Void)?
    // 设置字体大小
    var textFont = UIFont.systemFont(ofSize: 23)
    /// 文本框视图
    @IBOutlet weak var noteTextView: UITextView!
    // 点击添加按钮
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        addText("欢迎使用！")
    }
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
//        deleteText(NSRange(location: noteTextView.selectedRange.location - 3, length: 3))
        
        guard let image = UIImage(named: "Trash-circle") else {return}
        insertPic(image, mode: .fitTextLine)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        // 监听键盘发出的通知（通知的名称为：UIResponder.keyboardWillChangeFrameNotification）
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        noteTextView.text = noteTitle ?? ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        block?(noteTextView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextView.becomeFirstResponder()
    }
    
    // 添加文字
    private func addText(_ text: String) {
        // 获取textView的文本，并且转换成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        
        // 获取当前光标位置
        let selectedRange = noteTextView.selectedRange
        
        // 插入文字
        let attStr = NSAttributedString(string: text)
        mutableStr.insert(attStr, at: selectedRange.location)
        
        // 改变可变文本的字体属性
        mutableStr.addAttribute(NSAttributedString.Key.font, value: textFont, range: NSMakeRange(0, mutableStr.length))
        
        // 再次记住新的光标位置
        let newSelectedRange = NSMakeRange(selectedRange.location + mutableStr.length, 0)
        
        // 重新给文本赋值
        noteTextView.attributedText = mutableStr
        
        // 恢复光标位置(上面代码执行之后，光标会移到最后面)
        noteTextView.selectedRange = newSelectedRange
        
    }
    
    // 删除文字
    private func deleteText(_ range: NSRange) {
        // 获取可变文字
        let mutableStr = NSMutableAttributedString(attributedString: noteTextView.attributedText)
        // 获取当前光标位置
        let selectedRange = noteTextView.selectedRange
        /// FIXME : - 删除到最后崩溃！
        // 删除文字
        if range.location >= 3 {
            mutableStr.deleteCharacters(in: range)
        } else {
            mutableStr.deleteCharacters(in: NSRange(location: selectedRange.location, length: mutableStr.length))
        }
        
        // 记录当前光标位置
        let newSelectedRange = NSMakeRange(selectedRange.location - range.length, 0)
        // 设置文字字体大小
        mutableStr.addAttribute(NSAttributedString.Key.font, value: textFont, range: NSMakeRange(0, mutableStr.length))
        
        // 给文本重新赋值
        noteTextView.attributedText = mutableStr
        // 恢复光标位置
        noteTextView.selectedRange = newSelectedRange
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
        print("接收到\(notification.name)的通知")
        
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else {return}
        if frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: duration) {
                self.toolBar.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        } else {
            UIView.animate(withDuration: duration) {
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
