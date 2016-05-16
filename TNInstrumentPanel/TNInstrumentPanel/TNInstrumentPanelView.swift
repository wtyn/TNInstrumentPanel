//
//  TNInstrumentPanel.swift
//  TNInstrumentPanel
//
//  Created by wwy on 16/5/3.
//  Copyright © 2016年 wwy. All rights reserved.
//

import UIKit

class TNInstrumentPanelView: UIView {

    // 最大值
    var maxValue: CGFloat = 0.0
    
    
    // 当前值
    var currentValue: CGFloat = 0.0
    var showValueLabel: UILabel?
    
    // 单位
    var units: String?
    var showUnitsLabel: UILabel?
    
    var ctx: CGContext!
    
    
    // 指针
    var pointImgView: UIImageView?
    
    
    // 记录上次的角度
    var previousAngle: CGFloat = CGFloat((-M_PI * 3) / 10)
    
    
    // 半径
    var radius: CGFloat = 0.0
    let pieceAngle: CGFloat = CGFloat(M_PI * 2 / 5)
    
    
    override func drawRect(rect: CGRect) {
        ctx = UIGraphicsGetCurrentContext()
        radius = (self.bounds.size.width - 20) / 2.0
        self.drawPanelWithSize(rect.size)
        
    }
    
    //MARK: - 绘制表盘
    func drawPanelWithSize(size: CGSize) {
        
       
        // 四段,总共分为5段,只取其中的4端
        for index in 0 ..< 4{
            let path = self.drawArcWith(index)
             CGContextAddPath(ctx, path.CGPath)
             arcColorWith(index).set()
             CGContextSetLineWidth(ctx, 5.0)
             CGContextStrokePath(ctx)
            
            // 绘制刻度 和值
            drawScaleWith(index)
            
        }
       
        // 单位
        if showUnitsLabel != nil {
            showUnitsLabel!.removeFromSuperview()
        }
        showUnitsLabel = UILabel.init(frame: CGRectMake(0, 0, 80, 20))
        showUnitsLabel!.textAlignment = .Center
        showUnitsLabel!.font = UIFont.systemFontOfSize(11)
        showUnitsLabel!.textColor = UIColor.whiteColor()
        showUnitsLabel!.text = units
        showUnitsLabel!.center = CGPointMake(size.width / 2.0, size.height / 2.0 - 20.0)
        self.addSubview(showUnitsLabel!)

        
        
        // 显示当前值
        if showValueLabel != nil {
            showValueLabel!.removeFromSuperview()
        }
        showValueLabel = UILabel.init(frame: CGRectMake(0, 0, 80, 40))
        showValueLabel!.text = "\(currentValue)"
        showValueLabel!.textAlignment = .Center
        showValueLabel!.font = UIFont.boldSystemFontOfSize(17)
        showValueLabel!.textColor = UIColor.whiteColor()
        showValueLabel!.center = CGPointMake(size.width / 2.0, size.height / 2.0 + 20.0)
        self.addSubview(showValueLabel!)
        
        
        // 显示指针
        showCurrentValue()
        
    
        
        
    }
    
    
    // 绘制四段
    func drawArcWith(index: Int) ->UIBezierPath {
        // 每一块的弧度
        let startAngle = CGFloat((M_PI * 7) / 10 ) + pieceAngle * CGFloat(index)
        let endAngle = startAngle + pieceAngle
        let path = UIBezierPath.init(arcCenter:CGPointMake(radius + 10.0, radius + 10.0) , radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        return path
    }
    
    
    // 弧线的颜色
    func arcColorWith(index: Int) -> UIColor {
        switch index {
            
        case 0:
            return UIColor.init(red: 249 / 255.0, green: 204 / 255.0, blue: 30 / 255.0, alpha: 1)
        case 1,2:
            return UIColor.init(red: 111 / 255.0, green: 199 / 255.0, blue: 79 / 255.0, alpha: 1)
        case 3:
            return UIColor.init(red: 244 / 255.0, green: 26 / 255.0, blue: 59 / 255.0, alpha: 1)
            
        default:
            return UIColor.blackColor()
        }
    }
    
    
    //MARK: - 绘制刻度
    // index 为第几模块
    func drawScaleWith(index: Int) {
        // 将每一块平分为5个刻度
        for i in 0 ..< 5 {
                drawOneScaleWith(index, one: i)
            if index == 3 { // 在末尾再添加个刻度
                drawOneScaleWith(index, one: 5)
            }
        }
        
        
    }
    
    
    // 画出某个部分的某个刻度
     func drawOneScaleWith(index: Int, one: Int) {
        
        // 刻度的长度
        let scaleLong: CGFloat = 10.0
        // 修改开始刻度半径和颜色
        var radius2 = radius
        if one == 0 || one == 5 { // 修改刻度和颜色
            radius2 = radius + 2
            UIColor.whiteColor().set()
            CGContextSetLineWidth(ctx, 4.0)
        }else{
            arcColorWith(index).set()
            CGContextSetLineWidth(ctx, 2.0)
        }
        
        // 开始角度
        let startAngle =  CGFloat((M_PI * 7) / 10 ) + pieceAngle * CGFloat(index)
        // 每个刻度的角度
        let oneScaleAngle = startAngle + pieceAngle / 5.0 * CGFloat(one)
        // 绘制刻度
        let startPoint = CGPointMake(10 + radius + cos(oneScaleAngle) * radius2, 10 + radius + sin(oneScaleAngle) * radius2)
        let endPoint = CGPointMake(10 + radius + cos(oneScaleAngle) * (radius - scaleLong), 10 + radius + sin(oneScaleAngle) *  (radius - scaleLong))
    
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        CGContextAddPath(ctx, path.CGPath)
        CGContextStrokePath(ctx)
        
        // 显示刻度的值
        if maxValue > 0.0 {
          
                let value = (maxValue / 20.0) * CGFloat(index * 5 + one)
                var valueStr: NSString = NSString.init(format: "%0.1f", value)
                let attr1 = [NSFontAttributeName: UIFont.systemFontOfSize(10.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
                let attr2 = [NSFontAttributeName: UIFont.systemFontOfSize(15.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
                var attr = attr1
                var drawPoint: CGPoint = endPoint
                
                switch index {
                case 0:
                    if one == 0 {
                        valueStr = "0"
                        drawPoint = CGPointMake(endPoint.x , endPoint.y - 17.0)
                        attr = attr2
                    }else{
                        drawPoint = CGPointMake(endPoint.x + 2.0 , endPoint.y - 8.0)
                    }
                    
                case 1:
                    if one == 0 {
                        drawPoint = CGPointMake(endPoint.x + 5.0, endPoint.y - 8.0)
                        attr = attr2
                    }else{
                        if one == 4 {
                            drawPoint = CGPointMake(endPoint.x - 8.0, endPoint.y)
                        }
                        
                    }
                    
                case 2:
                    
                    let size = valueStr.sizeWithAttributes(attr)
                    if one == 0 {
                        drawPoint = CGPointMake(endPoint.x - size.width / 2.0 , endPoint.y + 12.0)
                        attr = attr2
                    }else{
                        if one == 1 {
                            drawPoint = CGPointMake(endPoint.x - size.width + 10.0 , endPoint.y )
                        }else{
                            drawPoint = CGPointMake(endPoint.x - size.width + 2.0 , endPoint.y )
                        }
                        
                    }
                    
                    
                case 3:
                    let size = valueStr.sizeWithAttributes(attr)
                    if one == 0 || one == 5 {
                        if one == 5 { // 最后一个刻度
                            valueStr = NSString.init(format: "%0.0f", maxValue)
                            drawPoint = CGPointMake(endPoint.x - size.width , endPoint.y - 17.0)
                        }else{
                            drawPoint = CGPointMake(endPoint.x - size.width - 10.0, endPoint.y - 8.0)
                        }
                        attr = attr2
                    }else{
                        drawPoint = CGPointMake(endPoint.x -  size.width - 2.0 , endPoint.y - 8.0)
                    }
                    

                default:
                    drawPoint = CGPointMake(0, 0)
                    
                }
                
                valueStr.drawAtPoint(drawPoint, withAttributes: attr)
            
            
        }
       

    }
    
    
    //MARK: - 显示指针
    func showCurrentValue() {
        
        if pointImgView == nil {
            creatPointImgView()
        }else{
            pointImgView!.removeFromSuperview()
            creatPointImgView()
        }
        
        rotateWithCurrentValue()
        
    }
    
    // 创建指针
    func creatPointImgView() {
        let size = self.bounds.size
        let center = CGPointMake(size.width / 2.0, size.height / 2.0)
        pointImgView = UIImageView(frame: CGRectMake(0, 0, center.x - 40, 3))
        pointImgView!.backgroundColor = UIColor.whiteColor()
        pointImgView!.layer.anchorPoint = CGPointMake(0.9, 0.5)
        pointImgView!.layer.position = center
//        pointImgView!.layer.transform = CATransform3DMakeRotation(CGFloat((-M_PI * 3) / 10), 0, 0, 1);
        pointImgView!.transform = CGAffineTransformMakeRotation(CGFloat((-M_PI * 3) / 10))
        self.addSubview(pointImgView!)
        
    }
    
    // 旋转角度
    func rotateWithCurrentValue() {
        if maxValue <= 0.0 || currentValue <= 0.0 {
            return
        }
        
        let perValueAngle: CGFloat = CGFloat(M_PI * 8 / 5.0) / maxValue
        
        let rotateAngle: CGFloat = perValueAngle * (currentValue < maxValue ? currentValue : maxValue)
        
        let currentAngle: CGFloat = rotateAngle + CGFloat((-M_PI * 3) / 10)

        let changeAngle = currentAngle - previousAngle
        previousAngle = currentAngle
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveLinear, animations: {
           
            if changeAngle  > CGFloat(M_PI) || changeAngle <  CGFloat(-M_PI) {
                 self.pointImgView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
//                self.pointImgView!.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 0, 1);
            }else{
                 self.pointImgView!.transform = CGAffineTransformMakeRotation(currentAngle)
//                self.pointImgView!.layer.transform = CATransform3DMakeRotation(currentAngle, 0, 0, 1);
            }
            
            }) { (finished) in
                
                if changeAngle  > CGFloat(M_PI) || changeAngle <  CGFloat(-M_PI) {
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveLinear, animations:  {
                        self.pointImgView!.transform = CGAffineTransformMakeRotation(currentAngle)
//                        self.pointImgView!.layer.transform = CATransform3DMakeRotation(currentAngle, 0, 0, 1);
                        
                    }) { (finished) in
                        
                    }

                }
                
                
                
        }
        
    
        
       
    }
    
    
    //MARK: - 改变值 -- 外部使用方法
    func changeWithValue(value: CGFloat, maxValue: CGFloat, units: String) {
       
        if value != self.currentValue {
            showValueLabel?.text = "\(value)"
        }
        
        if units != self.units {
            showUnitsLabel?.text = units
        }
    
        self.units = units
        if maxValue == self.maxValue { // 最大值未改变
            if currentValue != value {
                self.currentValue = value
                self.rotateWithCurrentValue()
            }
            
        }else{
            self.maxValue = maxValue
            self.currentValue = value
            self.setNeedsDisplay()

        }
        
        
    }
   
   

}
