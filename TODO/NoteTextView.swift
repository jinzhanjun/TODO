//
//  NoteTextView.swift
//  TODO
//
//  Created by 金占军 on 2019/10/31.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
    var lineStyleLabel: UILabel?
    var placeHolderStr: String? {
        didSet{
            setupUI(withPlaceHolder: placeHolderStr!)
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(withPlaceHolder: String) {
        let frame = CGRect(x: 0, y: 0, width: 10, height: 44)
        lineStyleLabel = UILabel(frame: frame)
        lineStyleLabel?.text = withPlaceHolder
        lineStyleLabel?.textColor = UIColor.darkGray
        lineStyleLabel?.contentMode = .scaleToFill
        lineStyleLabel?.sizeToFit()
        // 设置内边距（两侧）
        textContainer.lineFragmentPadding = 35
        insertSubview(lineStyleLabel!, at: 0)
    }
    func addLineStyleLabel(by rect: CGRect, with string: String) {
        let lineStyleLabel = UILabel()
        lineStyleLabel.text = string
        lineStyleLabel.textColor = UIColor.darkGray
        lineStyleLabel.font = UIFont.systemFont(ofSize: 15)
        lineStyleLabel.sizeToFit()
        let y = rect.maxY + rect.height / 2
        lineStyleLabel.center = CGPoint(x: 20, y: y)
        addSubview(lineStyleLabel)
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
