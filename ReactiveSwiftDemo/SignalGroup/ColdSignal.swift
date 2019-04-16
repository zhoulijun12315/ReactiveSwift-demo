//
//  coldSignal.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/15.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import ReactiveSwift


class ColdSignal {
    
}

//MARK - 冷信号
//冷信号需要一个唤醒操作, 然后才能发送事件, 而这个唤醒操作就是订阅它. 因为订阅后才发送事件, 显然, 冷信号不存在时机早晚的问题
//可以看到每次来一个新订阅者，消息都会重发一遍
extension ColdSignal {
    
    func createColdSignal() {
        let producer = SignalProducer<Int, NoError> { (innerObserver, lifetime) in
            lifetime.observeEnded({
                print("信号无效了 你可以在这里进行一些清理工作")
            })
            
            innerObserver.send(value: 1)
            innerObserver.send(value: 2)
            innerObserver.sendCompleted()
        }
        
        let outerObserver1 = Signal<Int, NoError>.Observer(value: { (value) in
            print("outerObserver1: \(value)")
        })
        producer.start(outerObserver1)
        
        let outerObserver2 = Signal<Int, NoError>.Observer(value: { (value) in
            print("outerObserver2: \(value)")
        })
        producer.start(outerObserver2)
        
        producer.startWithValues { (value) in
            print("producer 监控值: \(value)")
        }
        
    }
}
