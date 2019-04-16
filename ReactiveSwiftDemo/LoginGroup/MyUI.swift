//
//  MyUI.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/16.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result
import ReactiveSwift


class MyUI: UIView {
    var myTitle: String?
    var showLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required convenience init() {
        self.init(frame: CGRect.zero)
        
        showLabel = UILabel()
        showLabel.backgroundColor = UIColor.red
        showLabel.text = myTitle
        self.addSubview(showLabel)
        showLabel.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}


extension Reactive where Base: MyUI {
    var myTitle: BindingTarget<String?> {
        return makeBindingTarget{
            $0.showLabel.text = $1
            $0.myTitle = $1
        }
    }
}
