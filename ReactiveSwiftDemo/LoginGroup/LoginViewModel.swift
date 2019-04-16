//
//  LoginViewModel.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/16.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import ReactiveSwift

struct LoginError: Swift.Error {
    var code: Int
    var reason = ""
    
    init(code: Int, reason: String) {
        self.code = code
        self.reason = reason
    }
}

typealias AnyAPIProducer = ReactiveSwift.SignalProducer<Any?, LoginError>
typealias AnyAction = ReactiveSwift.Action<Any?, Any?, NoError>
typealias AnyAPIAction = ReactiveSwift.Action<Any?, Any?, LoginError>


class LoginViewModel {
    //Property和MutableProperty 本质上属于热信号，只提供一种状态的事件。就是此种类型的value值改变的事件
    var phoneString = MutableProperty<String?>(nil)
    var passwordString = MutableProperty<String?>(nil)
    
    var inputVaild: Property<Bool> {
        return Property.combineLatest(self.phoneString, self.passwordString).map {
            return $0?.count == 11 && $1?.count == 6
        }
    }
    
//    var submitAction = Action<Any?, Any?, LoginError>(enabledIf: self.inputVaild) { [unowned self] (input) -> SignalProducer<Any?, LoginError> in
//        return SignalProducer<Any?, LoginError>
//    }
    
    private(set) lazy var loginAction = AnyAPIAction(enabledIf: self.inputVaild) { [unowned self] _ -> AnyAPIProducer in
        //逻辑处理
        return AnyAPIProducer({ (innerObserver, _) in
            //发起网络请求
            innerObserver.send(value: "111")
            //一旦发送error，则结束
            //innerObserver.send(error: LoginError.init(code: 500, reason: "failed..."))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                innerObserver.send(value: "222")
                innerObserver.sendCompleted()
            })
        })
    }
    
    init() {
        phoneString.producer.startWithValues { (value) in
            print("获取到手机号： \(String(describing: value))")
        }
    }
}
