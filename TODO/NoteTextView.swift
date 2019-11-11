//
//  NoteTextView.swift
//  TODO
//
//  Created by 金占军 on 2019/10/31.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
    var textFont = UIFont.systemFont(ofSize: 23)
    
    let lineFragmentPadding: CGFloat = 40
    
    var lineStyleLabelModelArray: [lineStyleLabelModel]? {
        didSet {
            guard let modelArray = lineStyleLabelModelArray,
                let labelArray = lineStyleLabelArray
                else {return}
            for label in labelArray {
                label.removeFromSuperview()
            }
            for model in modelArray {
                addLineStyleLabel(by: model.location, with: model.name)
            }
        }
    }
    
    var lineStyleLabel: UILabel?
    lazy var lineStyleLabelArray: [UILabel]? = []
    var placeHolderStr: String? {
        didSet{
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.textContainer.lineFragmentPadding = lineFragmentPadding
    }
    
    func addLineStyleLabel(by rect: CGRect, with string: String) {
        lineStyleLabel = UILabel()
        lineStyleLabel?.text = string
        lineStyleLabel?.textColor = UIColor.darkGray
        lineStyleLabel?.font = UIFont.systemFont(ofSize: 15)
        lineStyleLabel?.sizeToFit()
        let y = rect.maxY + rect.height / 2
        lineStyleLabel?.center = CGPoint(x: 20, y: y)
        addSubview(lineStyleLabel!)
        lineStyleLabelArray?.append(lineStyleLabel!)
    }
    
    // 插入图片
    public func insertPic(_ image: UIImage, mode: ImageAttachmentMode = .default) {
        
        // 获取noteTextView的所有文本，转成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        // 创建图片附件
        let imageAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imageAttachmentString: NSAttributedString
        
        //设置图片的显示方式
        if mode == .fitTextLine {
            let rect = CGRect(x: 0, y: -4, width: self.font!.lineHeight, height: self.font!.lineHeight)
            // 与文字一样大小
            imageAttachment.bounds = rect
            imageAttachment.image = imageResize(img: image, withSize: rect.size)
        } else if mode == .fitTextView {
            // 撑满一行
            let imageWidth = self.frame.width - 10 - 2 * self.lineFragmentPadding
            let imageHeight = image.size.height / image.size.width * imageWidth
            let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            imageAttachment.bounds = rect
            imageAttachment.image = imageResize(img: image, withSize: rect.size)
        }
        
        
        imageAttachmentString = NSAttributedString(attachment: imageAttachment)
        
        // 获得目前光标的位置
        let selectedRange = self.selectedRange
        // 插入文字
        mutableStr.insert(imageAttachmentString, at: selectedRange.location)
        
        // 设置可变字体的字体属性
        mutableStr.addAttributes([NSAttributedString.Key.font : textFont], range: NSMakeRange(0, mutableStr.length))
        // 再次记住光标位置
        let newSelectedRange = NSMakeRange(mutableStr.length + 1, 0)
        
        // 重新给文本赋值
        self.attributedText = mutableStr
        
        // 恢复光标位置（上面代码执行完毕之后，光标会移到最后面）
        self.selectedRange = newSelectedRange
        
        // 移动滚动条（确保光标在可视区域之内）
        self.scrollRangeToVisible(newSelectedRange)
    }
    
    
    // 添加文字
    @objc public func addText() {
        // 获取textView的文本，并且转换成可变文本
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        
        // 获取当前光标位置
        let selectedRange = self.selectedRange
        
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
        self.attributedText = mutableStr
        
        // 恢复光标位置(上面代码执行之后，光标会移到最后面)
        self.selectedRange = newSelectedRange
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

extension UILabel {
    override open var center: CGPoint {
        didSet {
            self.frame.origin.x = self.center.x - self.bounds.width / 2
            self.frame.origin.y = self.center.y - self.bounds.height / 2
        }
    }
}
