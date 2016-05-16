//
//  ViewController.swift
//  TNInstrumentPanel
//
//  Created by wwy on 16/5/3.
//  Copyright © 2016年 wwy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var panelView: TNInstrumentPanelView!
    
    var tachometerView: TNTachometerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        panelView = TNInstrumentPanelView()
        panelView.frame = CGRectMake(0, 0, 250, 250)
        panelView.backgroundColor = UIColor.blackColor()

        self.view.addSubview(panelView)
        panelView.maxValue = 100

        
//        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(ViewController.changeValue), userInfo: nil, repeats: true)
      
        
        tachometerView = TNTachometerView(frame: CGRectMake(100, 300, 250, 250))
        self.view.addSubview(tachometerView)
        tachometerView.maxValue = 2000
        
        tachometerView.changeWithValue(2500, maxValue: 3000, units: "这是单位")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    

    
    
    func changeValue() {
       
        let value = CGFloat(arc4random() % 100)
        
        panelView.changeWithValue(value, maxValue: 100, units: "这是单位")
        tachometerView.changeWithValue(value, maxValue: 100, units: "这是单位")
    }
    
    

}

