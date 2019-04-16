//
//  SignalFunction.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/15.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import ReactiveSwift

struct MyError: Swift.Error {
    let code: Int
    var reason = ""
}


// signal热信号和Producer.都拥有以下功能
class SignalFunction {
    init() {
//        self.testProperty()
        self.testAction()
    }
    
    
    //MARK map
    //映射一个新值,生成一个新Signal，可以ObserveValues来观察新产生的值
    func testMap() {
        let (mapSignal, mapInnerObserver) = Signal<String, NoError>.pipe()
        mapSignal.map{
            return "Map:  " + "Hello" + $0
            }.observeValues{
                print("Map:  Result: \($0)")
        }
        
        mapInnerObserver.send(value: "World")
        mapInnerObserver.sendCompleted()
    }
    
    
    
    //MARK on
    //类似map。可以在事件和订阅者中间穿插一段逻辑。
    func testOn() {
        let (onSignal, onInnerObserver) = Signal<String, NoError>.pipe()
        onSignal.on { (value) in
            print("on ...")
            }.observeValues { (value) in
                print("On Result: \(value)")
        }
        
        onInnerObserver.send(value: "on Test")
        onInnerObserver.sendCompleted()
    }
    
    //MARK take(until:)
    //在   xxx.take(until：yyy)； yyy发送事件之前,xxx的发送可以一直正常。直到yyy发送事件，则xxx停止发送
    func testTakeUntil() {
        let (takeUntilSigal1, innerTakeUntilObserver1) = Signal<Int, NoError>.pipe()
        let (takeUntilSigal2, innerTakeUntilObserver2) = Signal<(), NoError>.pipe()
        takeUntilSigal1.take(until: takeUntilSigal2).observeValues {
            print("Take Until:   received value \($0)")
        }
        
        innerTakeUntilObserver1.send(value: 1)
        innerTakeUntilObserver1.send(value: 2)
        innerTakeUntilObserver2.send(value: ())
        innerTakeUntilObserver1.send(value: 3)
        
        innerTakeUntilObserver1.sendCompleted()
        innerTakeUntilObserver2.sendCompleted()
    }
    
    //MARK take(first: xxx) 只取最初的xxx次发送Event；
    //take(last: yyy) 只取最后yyy次发送event
    func testTakeFirstAndLast() {
        let (signalTakeFirst, innerObserverTakeFirst) = Signal<Int, NoError>.pipe()
        signalTakeFirst.take(first: 2).observeValues { (value) in
            print("take first get value: \(value)")
        }
        innerObserverTakeFirst.send(value: 1)
        innerObserverTakeFirst.send(value: 2)
        innerObserverTakeFirst.send(value: 3)
        innerObserverTakeFirst.send(value: 4)
        innerObserverTakeFirst.sendCompleted()
        
        let (signalTakeLast, innerObserverTakeLast) = Signal<Int, NoError>.pipe()
        signalTakeLast.take(last: 1).observeValues { (value) in
            print("take last get value: \(value)")
        }
        innerObserverTakeLast.send(value: 11)
        innerObserverTakeLast.send(value: 22)
        innerObserverTakeLast.send(value: 33)
        innerObserverTakeLast.sendCompleted()
    }
    
    //MARK  merge
    //合并多个信号为一个新信号，任何一个被合并的信号有event发来，都会被激活
    func testMerge() {
        let (mergeSignal1, mergeInnerObserver1) = Signal<Int, NoError>.pipe()
        let (mergeSignal2, mergeInnerObserver2) = Signal<Int, NoError>.pipe()
        let (mergeSignal3, mergeInnerObserver3) = Signal<Int, NoError>.pipe()
        
        Signal.merge(mergeSignal1, mergeSignal2, mergeSignal3).observeValues {
            print("merge get values: \($0)")
        }
        
        mergeInnerObserver1.send(value: 1)
        mergeInnerObserver1.sendCompleted()
        
        mergeInnerObserver2.send(value: 2)
        mergeInnerObserver2.sendCompleted()
        
        mergeInnerObserver3.send(value: 3)
        mergeInnerObserver3.sendCompleted()
    }
    
    //MARK combineLatest
    //多个信号组合成一个新信号；
    //Important!!! 要所有信号都有一个event才可以，有一个没发送event，则组合信号不会被触发。
    func testCombineLatest() {
        
        let (combineLatestSignal1, combineInnerObserver1) = Signal<Int, NoError>.pipe()
        let (combineLatestSignal2, combineInnerObserver2) = Signal<Int, NoError>.pipe()
        let (combineLatestSignal3, combineInnerObserver3) = Signal<Int, NoError>.pipe()
        Signal.combineLatest(combineLatestSignal1, combineLatestSignal2, combineLatestSignal3).observeValues {
            print("combineLastest values: \($0)")
        }
        combineInnerObserver1.send(value: 6)
        combineInnerObserver2.send(value: 7)
        combineInnerObserver3.send(value: 8)
        
        combineInnerObserver1.send(value: 66)
        combineInnerObserver2.send(value: 77)
        //combineInnerObserver3.send(value: 88)
        
        combineInnerObserver1.sendCompleted()
        combineInnerObserver2.sendCompleted()
        combineInnerObserver3.sendCompleted()
    }
    
    //MARK zip
    //链式信号（压缩信号）。把多个信号合并成一个相同的。但是，信号必须是一一对应，每次都要交互触发才会形成新信号.信号对齐。
    func testZip() {
        let (zipSignal1, zipObserver1) = Signal<Int, NoError>.pipe()
        let (zipSignal2, zipObserver2) = Signal<Int, NoError>.pipe()
        let (zipSignal3, zipObserver3) = Signal<Int, NoError>.pipe()
        Signal.zip(zipSignal1, zipSignal2, zipSignal3).observeValues {
            print("zip values: \($0)")
        }
        zipObserver1.send(value: 9)
        zipObserver2.send(value: 10)
        zipObserver3.send(value: 11)
        
        zipObserver1.send(value: 29)
        zipObserver2.send(value: 30)
        //zipObserver3.send(value: 31)
        
        zipObserver1.sendCompleted()
        zipObserver2.sendCompleted()
        zipObserver3.sendCompleted()
    }
    
    //Property.value不可设置, MutableProperty.value可设置
    // Property/MutableProperty内部有一个Producer一个Signal, 设置value即是在向这两个信号发送Value事件即可.
    func testProperty() {
        print("Property 测试")

        
        let mutableProperty = MutableProperty(1)
        print("property value: \(mutableProperty.value)")
        
        mutableProperty.producer.startWithValues { /** 冷信号可以收到初始值value=1和2,3 */
            print("producer received \($0)")
        }
        
        mutableProperty.signal.observeValues { /** 热信号只能收到后续的变化值value=2,3 */
            print("signal received \($0)")
        }
        mutableProperty.value = 2 /** 设置value值就是在发送Value事件 */
        mutableProperty.value = 3 /** 设置value值就是在发送Value事件 */
    }
    
    
    //typealias APIProducer<T> = SignalProducer<T, MyError>
    //typealias APIAction<T> = Action<Any?, T, MyError>
    //Action是最后一种发送事件的途径, 不过和其他途径不同, 它并不直接发送事件, 而是生产信号, 由生产的信号来发送事件.
    //最重要的是, Action是唯一一种可以接受订阅者输入的途径.
    //Action<x,y,z> 范型，从左到右，依次为输入类型，输出类型，错误类型
    func testAction() {
        let action = Action<Any?, String, MyError> { (input) -> SignalProducer<String, MyError> in
            print("input: \(String(describing: input))")
            
            return  SignalProducer<String, MyError> ({ (innerObserver, _) in
                //发起网络请求
                innerObserver.send(value: "111")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    innerObserver.send(value: "222")
                    innerObserver.sendCompleted()
                })
            })
        }
        
        //2. 订阅Action的执行事件 Action.events可以订阅Action本身的事件
        action.events.observe { print("did received Event: \($0)") }
        
        //3. 订阅Action的各种输出事件
        //Action.values/errors/completed可以订阅初始化闭包中返回的SignalProducer的各种事
        action.values.observeValues { print("did received Value: \($0)")  }
        //action.errors.observeValues { print("did received Error: \($0)")  }
        //action.completed.observeValues { print("did received completed: \($0)") }
        
        //4. 执行Action 开始输出
        action.apply("hello").start()
        
        //5. 在返回的Producer还未结束前继续执行Action 什么也不会输出
        for i in 0...10 {
            action.apply([String(i): "xxx"]).start()
        }
        
    }
    
}
