//
//  NoteTextView.swift
//  TODO
//
//  Created by 金占军 on 2019/10/31.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
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
}

extension UILabel {
    override open var center: CGPoint {
        didSet {
            self.frame.origin.x = self.center.x - self.bounds.width / 2
            self.frame.origin.y = self.center.y - self.bounds.height / 2
        }
    }
}
