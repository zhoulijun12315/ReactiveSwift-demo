//
//  ViewController.swift
//  ReactiveSwiftDemo
//
//  Created by lee_zhou on 2019/4/12.
//  Copyright © 2019 lijun.zhou. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import ReactiveSwift
import SnapKit


class ViewController: UIViewController {
    var signalFunction: SignalFunction = SignalFunction()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // snapkit用法
        let demoView: UIView = UIView()
        demoView.backgroundColor = UIColor.orange
        self.view.addSubview(demoView)
        //四边都距离30px
        demoView.snp.makeConstraints{
            $0.top.bottom.left.right.equalToSuperview().inset(30)
        }
        
        let demoLabel: UILabel = UILabel()
        demoLabel.backgroundColor = UIColor.white
        demoLabel.text = "demo show"
        demoLabel.textColor = UIColor.darkGray
        self.view.addSubview(demoLabel)
        demoLabel.snp.makeConstraints{
            $0.center.equalToSuperview()  //居中
        }
        
        
        let demoButton: UIButton = UIButton()
        demoButton.backgroundColor = UIColor.blue
        demoButton.setTitle("ReactiveCocoa 替代cocoa方法", for: .normal)
        self.view.addSubview(demoButton)
        demoButton.snp.makeConstraints{
            $0.top.equalTo(demoLabel.snp.bottom).offset(20)  //距离demoLable的底部，20px
            
            $0.left.equalTo(40)
            $0.right.equalTo(-40)
//            $0.left.right.equalToSuperview().inset(40)  等价于上面那两句
        }
        
        demoButton.reactive.controlEvents(.touchUpInside).observeValues { (btn) in
            self.navigationController?.pushViewController(DemoController(), animated: true)
        }
    }
}
