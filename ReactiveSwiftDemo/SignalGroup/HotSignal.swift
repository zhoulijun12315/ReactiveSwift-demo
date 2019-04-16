//
//  hotSignal.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/15.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import Foundation

import ReactiveCocoa
import Result
import ReactiveSwift


class HotSignal {
    
}



//MARK - 创建信号
//创建热信号信号
//（热信号必须被订阅，才会收到信息。类似直播。 热信号是主动的，即使你没有订阅事件，它仍然会时刻推送。）
//热信号可以有多个订阅者，是一对多，集合可以与订阅者共享信息。
extension HotSignal {
    
    func  createHotSignal() {
        //1. 热信号
        //pipe会返回一个元组， 元组第一个为output，类型signal，第二个为input，类型为 Observer。
        //通过output 订阅信号，通过input发送信号
        //创建signal(output)和innerObserver(input)
        let (signal, innerObserver) = Signal<Int, NoError>.pipe()
        
        //创建Observer1
        let outObserver1 = Signal<Int, NoError>.Observer(value: { value in
            print("观察者1： \(value)")
        })
        
        //创建Observer2
        let outerObserver2 = Signal<Int, NoError>.Observer { (event) in
            switch event {
            case let .value(value):
                print("观察者2: \(value)")
            default: break
            }
        }
        
        signal.observeInterrupted {
            print("interrupted!!!")
        }
        
        signal.observeCompleted {
            print("completed!!!")
        }
        
        //why 这个send 000,订阅者没有接受到？？
        
        innerObserver.send(value: 1)      //信号过早订阅，没有信息发送
        
        signal.observe(outObserver1)
        signal.observe(outerObserver2)
        innerObserver.send(value: 2)        //有效发送值
        
        //innerObserver.sendCompleted()       //发送完成信号
        innerObserver.sendInterrupted()       //发送中断信号
        innerObserver.send(value: 3)
    }
}
