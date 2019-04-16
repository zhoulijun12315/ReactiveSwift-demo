//
//  SystemController.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/15.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result
import ReactiveSwift

class MyClass: NSObject {
    //why？ 要实用 @objc dynamic
    // @objc应用于变量是为了能够让变量表达为keypath字符串，进而使用kvc功能。
    // @objc dynamic应用于变量是为了让变量能够使用kvo机制。
    @objc dynamic var title: String?
    
    override init() {
        
    }
    
    convenience init(_ title: String) {
        self.init()
        self.title = title
    }
}



class demoController: UIViewController {
    var reactiveLabel: UILabel!
    var reactiveTextField: UITextField!
    var myClass: MyClass = MyClass("my")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        reactiveLabel = UILabel()
        reactiveLabel.text = "hello"
        reactiveLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        reactiveLabel.backgroundColor = UIColor.orange
        self.view.addSubview(reactiveLabel)
        
        reactiveTextField = UITextField()
        reactiveTextField.placeholder = "测试输入"
        reactiveTextField.backgroundColor = UIColor.gray
        self.view.addSubview(reactiveTextField)
        reactiveTextField.snp.makeConstraints{
            $0.top.equalTo(reactiveLabel.snp_bottom).offset(30)
            $0.left.right.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        self.demoFunction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}


//MARK - 替代系统方法
extension SystemFunctionController {
    func demoFunction() {
        //////////////////////////////////// 代替KVO ////////////////////////////////////
        ///////////// UI
        /////* UILabel text
        print("\r\n---- 代替KVO ----")
        reactiveLabel.reactive.producer(forKeyPath: "text").startWithValues { (value) in
            print("reactiveLabel.reactive text:  \(value!)")
        }
        reactiveLabel.text = "hello world"
        reactiveLabel.text = "hello world, ReactiveCocoa"
        
        /////* UILabel frame
        print("\r\nUILabel frame")
        reactiveLabel.reactive.producer(forKeyPath: "frame").startWithValues { (value) in
            print("reactiveLabel.reactive frame:  \(value!)")
        }
        reactiveLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        
        /////My Class
        print("\r\nMy Class")
        myClass.reactive.producer(forKeyPath: "title").startWithValues { (value) in
            print("myClass.reactive:  \(value!)")
        }
        myClass.title = "my name is lee"
        print("****** end ******")
        
        //////////////////////////////////// 代替通知 ////////////////////////////////////
        print("\r\n\r\n\r\n---- 代替通知 NotificationCenter ----")
        //        NotificationCenter.default.reactive.notifications(forName: Notification.Name("loadMore")).observeValues {
        //            if let userInfo = $0.userInfo?["info"] {
        //                print("userInfo:   \(userInfo)")
        //            }
        //            print("NotificationCenter:  \($0)")
        //        }
        
        
        NotificationCenter.default.reactive.notifications(forName: Notification.Name("loadMore")).take(duringLifetimeOf: self).observeValues {
            if let userInfo = $0.userInfo?["info"] {
                print("userInfo:   \(userInfo)")
            }
            print("NotificationCenter:  \($0)")
        }
        
        NotificationCenter.default.post(name: Notification.Name("loadMore"), object: nil, userInfo: ["info":"infoMessage"])
        NotificationCenter.default.post(name: Notification.Name("refresh"), object: nil, userInfo: ["info":"refresh"])
        
        
        //////////////////////////////////// 捕获系统函数调用 ////////////////////////////////////
        self.reactive.trigger(for: #selector(self.touchesBegan(_:with:))).observeValues {
            print("\r\n\r\n\r\n---- 捕获系统函数调用 ----")
            print("trigger touchsBegin")
        }
    }
}



