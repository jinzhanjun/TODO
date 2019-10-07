//
//  ItemModel.swift
//  TODO
//
//  Created by 金占军 on 2019/10/7.
//  Copyright © 2019 金占军. All rights reserved.
//

import Foundation
import UIKit

struct ItemModel: Encodable, Decodable {
    var text: String
    var isDone: Bool
}
