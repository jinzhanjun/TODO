//
//  NoteTextView.swift
//  TODO
//
//  Created by 金占军 on 2019/10/31.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {
    
    var placeHolder: UILabel?
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
        let frame = CGRect(x: textContainerInset.left, y: 0, width: 100, height: 44)
        placeHolder = UILabel(frame: frame)
        placeHolder?.text = withPlaceHolder
        placeHolder?.textColor = UIColor.darkGray
    }
}
