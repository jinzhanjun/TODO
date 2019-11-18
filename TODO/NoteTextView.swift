//
//  NoteTextView.swift
//  TODO
//
//  Created by 金占军 on 2019/10/31.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
    let defaultTextFont = UIFont.systemFont(ofSize: 23)
    
    // 设置默认段落样式
    let defaultParagraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    // 设置默认属性
    var defaultAttributes: [NSAttributedString.Key: Any] = [:]
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
        
        // 设置段落格式换行方式
        /***
         case byWordWrapping // Wrap at word boundaries, default     单词换行，第一行末尾和第二行末尾都保留完整的单词（默认）

         case byCharWrapping // Wrap at character boundaries   字符换行，与Clip的区别在第一行，将最后一个单词截断了

         case byClipping // Simply clip   裁剪，两行能显示多少就显示多少

         case byTruncatingHead // Truncate at head of line: "...wxyz"   头部截断，第一行末尾是完整单词，第二行最前面三个点来表示省略内容

         case byTruncatingTail // Truncate at tail of line: "abcd..."    尾部截断，第一行末尾是完整单词，第二行尾部三个点来省略内容

         case byTruncatingMiddle // Truncate middle of line:  "ab...yz"  中间截断，第一行末尾是完整单词，第二行中间三个点来表示省略内容
         ***/
        // 简单截断
        defaultParagraphStyle.lineBreakMode = .byCharWrapping
        // 行距 10
        defaultParagraphStyle.lineSpacing = 10
        // 与上一段间距 10
        defaultParagraphStyle.paragraphSpacingBefore = 10
        defaultAttributes = [NSAttributedString.Key.font: defaultTextFont, NSAttributedString.Key.paragraphStyle: defaultParagraphStyle]
        
        // 设置默认属性
        typingAttributes = defaultAttributes
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
        mutableStr.addAttributes([NSAttributedString.Key.font : defaultTextFont], range: NSMakeRange(0, mutableStr.length))
        // 再次记住光标位置
        let newSelectedRange = NSMakeRange(mutableStr.length + 1, 0)
        
        // 重新给文本赋值
        self.attributedText = mutableStr
        let height = NoteTextView.getAttributedStringRect(with: mutableStr, inTextView: self).height
        
        let tempSize = CGSize(width: UIScreen.main.bounds.width, height: height)
        
        self.frame.size = tempSize
        // 恢复光标位置（上面代码执行完毕之后，光标会移到最后面）
        self.selectedRange = newSelectedRange
        
        // 移动滚动条（确保光标在可视区域之内）
        self.scrollRangeToVisible(newSelectedRange)
    }
    // 添加文字
    @objc public func completed() {
        
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
    
    // 根据文本以及文本属性返回文本框大小
    class func getStringRect(with string: String, inTextView textView: UITextView, withAttributes: [NSAttributedString.Key: Any]) -> CGSize {
        // 获取textView内容的宽度
        var contentWidth = textView.frame.size.width
        // 需要删除边距
        // 计算边距宽度
        let broadWidth =
                textView.contentInset.left
                + textView.contentInset.right
                + textView.textContainerInset.left
                + textView.textContainerInset.right
                + textView.textContainer.lineFragmentPadding
                + textView.textContainer.lineFragmentPadding
        // 计算边距高度
        let broadHeight =
            textView.contentInset.top
            + textView.contentInset.bottom
            + textView.textContainerInset.top
            + textView.textContainerInset.bottom
        
        //删除宽度边距
        contentWidth -= broadWidth
        // 创建需要计算的文本内容大小
        let InSize = CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)

        let calculatedSize = string.boundingRect(with: InSize, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: withAttributes, context: nil).size
        
        let adjustSize = CGSize(width: ceil(calculatedSize.width), height: ceil(calculatedSize.height + broadHeight))
//        print("adjustSize = \(adjustSize)")
        return adjustSize
    }
    
    class func getAttributedStringRect(with attrString: NSAttributedString, inTextView textView: UITextView) -> CGSize {
        // 获取textView内容的宽度
        var contentWidth = textView.frame.size.width
        // 需要删除边距
        // 计算边距宽度
        let broadWidth =
            textView.contentInset.left
                + textView.contentInset.right
                + textView.textContainerInset.left
                + textView.textContainerInset.right
                + textView.textContainer.lineFragmentPadding
                + textView.textContainer.lineFragmentPadding
        // 计算边距高度
        let broadHeight =
            textView.contentInset.top
                + textView.contentInset.bottom
                + textView.textContainerInset.top
                + textView.textContainerInset.bottom
        
        //删除宽度边距
        contentWidth -= broadWidth
        // 创建需要计算的文本内容大小
        let InSize = CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let calculatedSize = attrString.boundingRect(with: InSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
        
        let adjustSize = CGSize(width: ceil(calculatedSize.width), height: ceil(calculatedSize.height + broadHeight))
        //        print("adjustSize = \(adjustSize)")
        return adjustSize
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
