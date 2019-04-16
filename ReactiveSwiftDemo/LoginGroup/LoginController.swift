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



class DemoController: UIViewController {
    var myClass: MyClass = MyClass("my")

    var reactiveLabel: UILabel!
    var phoneTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var myUI: MyUI!
    var loginViewModel: LoginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        reactiveLabel = UILabel()
        reactiveLabel.text = "hello"
        reactiveLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        reactiveLabel.backgroundColor = UIColor.orange
        self.view.addSubview(reactiveLabel)
        
        phoneTextField = UITextField()
        phoneTextField.placeholder = "输入手机号"
        phoneTextField.backgroundColor = UIColor.gray
        self.view.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints{
            $0.top.equalTo(reactiveLabel.snp_bottom).offset(30)
            $0.left.right.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        passwordTextField = UITextField()
        passwordTextField.placeholder = "输入密码"
        passwordTextField.backgroundColor = UIColor.gray
        self.view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints{
            $0.left.right.equalTo(phoneTextField)
            $0.top.equalTo(phoneTextField.snp_bottom).offset(30)
            $0.height.equalTo(40)
        }
        
        
        loginButton = UIButton()
        loginButton.setTitle("确定", for: .normal)
        loginButton.setTitleColor(UIColor.blue, for: .normal)
        loginButton.layer.borderColor = UIColor.black.cgColor
        loginButton.layer.borderWidth = 1.0
        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints{
            $0.top.equalTo(passwordTextField.snp_bottom).offset(30)
            $0.left.right.equalToSuperview().inset(50)
            $0.height.equalTo(40)
        }
        
        myUI = MyUI()
        self.view.addSubview(myUI)
        myUI.snp.makeConstraints{
            $0.top.equalTo(loginButton.snp_bottom).offset(30)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        self.demoFunction()
        self.bindModel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}


//MARK - 替代系统方法
extension DemoController {
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



//MARK - 登录demo测试
extension DemoController {
    //在mvvm模式中，可以自定义一个函数。在函数内集中对viewModel和view数据和事件进行绑定
    func bindModel() {
        //<~的左边是绑定目标(BindingTargetProvider), 右边则是数据源(BindingSource),
        //<~会把右边数据源的发送出的Value直接绑定到左边的目标上.
        loginViewModel.phoneString <~ phoneTextField.reactive.continuousTextValues
        loginViewModel.passwordString <~ passwordTextField.reactive.continuousTextValues
        
        //myUI为自定义控件。演示自定义的UI控件或者类型，如何做到数据绑定
        myUI.reactive.myTitle <~ passwordTextField.reactive.continuousTextValues
        
        
        
        
        //
        loginButton.reactive.isEnabled <~ loginViewModel.inputVaild
        
        //按钮事件绑定
        loginButton.reactive.pressed = CocoaAction(loginViewModel.loginAction){ _ in}
        
        loginViewModel.loginAction.values.observeValues { (value) in
            print("监听到 action事件内部发出的值 \(String(describing: value))")
        }
        
        loginViewModel.loginAction.errors.observeValues { (error) in
            print("监听到 action事件内部发出的错误 \(error)")
        }
    }
}
