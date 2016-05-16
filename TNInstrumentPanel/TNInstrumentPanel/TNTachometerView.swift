//
//  TNTachometerView.swift
//  TNInstrumentPanel
//
//  Created by wwy on 16/5/7.
//  Copyright © 2016年 wwy. All rights reserved.
//

import UIKit

class TNTachometerView: UIView {

    // 外部属性
    var maxValue: CGFloat = 0.0
    var currentValue: CGFloat = 0.0
    // 显示单位的label
    var unitLabel: UILabel!
    // 当前值的label
    var currentLabel: UILabel!
    
    
    // 自定义部分
    // 开始与X轴的夹角
    let startXAxisIncludedAngle: CGFloat = 45.0 / 180.0 * CGFloat(M_PI)
    // 三段弧的偏移量
    var offsetAngle: [CGFloat] = [-0.02, -0.05, 0.0, -0.05, -0.1, 0.0]
    
    // 记录上次的角度
    var previousAngle: CGFloat = 0.0

    
    // 每个小刻度的度数
    var pieceAngle: CGFloat = 0.0
    //半径
    var radius: CGFloat = 0.0
    // 内半径
    var inRadius: CGFloat = 0.0
    //外半径
    var outRadius: CGFloat = 0.0
    
    // 所有主刻度的旋转弧度
    var allMainAngleArr: [CGFloat] = []
    
    // 存放所有的刻度值得label
    var allScaleLabelArr: [UILabel] = []
    
    // 指针
    var pointImgView: UIImageView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        previousAngle = -startXAxisIncludedAngle
        radius = frame.size.width / 2.0
        
        // 创建单位和显示当前值
        creatShowLabel()
        // 指针
        creatPointImgView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        // 画刻度
        drawPlateWithRect(rect)
        // 显示值
        drawScaleValue()
        // 绘制圆
        drawCircle()
    }
    
    
    
    //MARK: - 绘制刻度盘
    func drawPlateWithRect(rect: CGRect) {
        
        // 总共的度数
        let allAngle = CGFloat(M_PI) + 2 * startXAxisIncludedAngle
        // 主分 14个刻度,再小分5个刻度
        pieceAngle = allAngle / 14.0 / 5.0
       
        // 刻度的半径
        outRadius = radius - 38.0
        inRadius = radius - 48.0
        var count = 0
        var rotateAngle: CGFloat = 0.0
        let ctx = UIGraphicsGetCurrentContext()
        //弧度的开始结束弧度
        var arcAngleArr: [CGFloat] = []
        // 绘制刻度
        while rotateAngle <= allAngle {
            var isMain = false
           
            if count % 5 == 0 { // 大刻度
                isMain = true
                
               
                switch count / 5 {
                case 0, 3, 4 ,11, 12, 14:
                    arcAngleArr.append(rotateAngle)
                    allMainAngleArr.append(rotateAngle)
                default:
                    allMainAngleArr.append(rotateAngle)
                }
                
            }
            
            let SEPoint = scaleStartAndEndPointWith(rotateAngle, isMain: isMain)
            let path = UIBezierPath()
            path.moveToPoint(SEPoint.startPoint)
            path.addLineToPoint(SEPoint.endPoint)
            CGContextAddPath(ctx, path.CGPath)
            UIColor.whiteColor().set()
            CGContextSetLineWidth(ctx, 2.0)
            CGContextStrokePath(ctx)
            rotateAngle += pieceAngle
            count += 1
        }
        
      
        if count != 71 { // 需要添加最后一个主刻度
            
            let SEPoint = scaleStartAndEndPointWith(allAngle, isMain: true)
            let path = UIBezierPath()
            path.moveToPoint(SEPoint.startPoint)
            path.addLineToPoint(SEPoint.endPoint)
            CGContextAddPath(ctx, path.CGPath)
            UIColor.whiteColor().set()
            CGContextSetLineWidth(ctx, 2.0)
            print(SEPoint)
            CGContextStrokePath(ctx)
            arcAngleArr.append(allAngle)
            allMainAngleArr.append(allAngle)
        }
        
        
        // 画出三段弧
        for index in 0 ... 2 {
            
            let path = UIBezierPath.init(arcCenter:CGPointMake(radius, radius) , radius: radius - 56, startAngle:CGFloat(M_PI)  - startXAxisIncludedAngle  + arcAngleArr[index * 2] + offsetAngle[index * 2] , endAngle:  CGFloat(M_PI) - startXAxisIncludedAngle + arcAngleArr[index * 2 + 1] + offsetAngle[index * 2 + 1], clockwise: true)
            arcColorWith(index).set()
            CGContextAddPath(ctx, path.CGPath)
            CGContextSetLineWidth(ctx, 5.0)
            CGContextStrokePath(ctx)
        }
        
       
    }
    
    // 弧线的颜色
    func arcColorWith(index: Int) -> UIColor {
        switch index {
            
        case 0:
            return UIColor.init(red: 249 / 255.0, green: 204 / 255.0, blue: 30 / 255.0, alpha: 1)
        case 1:
            return UIColor.init(red: 111 / 255.0, green: 199 / 255.0, blue: 79 / 255.0, alpha: 1)
        case 2:
            return UIColor.init(red: 244 / 255.0, green: 26 / 255.0, blue: 59 / 255.0, alpha: 1)
            
        default:
            return UIColor.blackColor()
        }
    }

    
    
    // 刻度的起始点
    // radian: 顺时针旋转角度
    func scaleStartAndEndPointWith(radian: CGFloat, isMain: Bool) -> (startPoint: CGPoint, endPoint: CGPoint) {

        let angle = CGFloat(M_PI)  - startXAxisIncludedAngle + radian
        let startPoint = CGPointMake(radius + outRadius * cos(angle), radius + outRadius * sin(angle))
        var mainInRadius = inRadius
        if isMain {
            mainInRadius = inRadius - 5.0
        }
        let endPoint = CGPointMake(radius + mainInRadius * cos(angle), radius + mainInRadius * sin(angle))
        return (startPoint, endPoint)
    }
    
    
    //MARK: - 画刻度的值
    func drawScaleValue() {
        if allScaleLabelArr.count > 0 {
            for label in allScaleLabelArr {
                label.removeFromSuperview()
            }
        }

        // 总分多少段
        let allCount = allMainAngleArr.count - 1

        if allCount <= 0 {
            return
        }
        
        // label的半径
        let labelRaius = radius - 28
        let everyValue = maxValue / CGFloat(allCount)
        let attr = [NSFontAttributeName: UIFont.systemFontOfSize(10)]
        for index in 0 ... allCount {
            let rotateAngle = startXAxisIncludedAngle + allMainAngleArr[index] + CGFloat(M_PI_2)
            let str = NSString.init(format: "%.0f", everyValue * CGFloat(index))
            let textSize = str.sizeWithAttributes(attr)
            var changeX: CGFloat = 0.0
            if index < Int(allCount / 2) {
                changeX = -textSize.width - 4.0
            }else if index == Int(allCount / 2) {
                changeX = -textSize.width / 2.0
            }else {
                changeX = -8.0
            }
           
            
            let label = UILabel.init(frame: CGRectMake(labelRaius * cos(rotateAngle) + radius + changeX, labelRaius * sin(rotateAngle) + radius - 10, textSize.width, textSize.width))
            label.text = str as String
            label.sizeToFit()
            label.font = UIFont.systemFontOfSize(11)
            if index <  Int(allCount / 2) {
                label.textAlignment = .Right
            }
            label.textColor = UIColor.whiteColor()
            self.addSubview(label)
            allScaleLabelArr.append(label)
        }
        
    }
    
    
    //画圆
    func drawCircle() {
        
        let ctx = UIGraphicsGetCurrentContext()
        let path = UIBezierPath.init(arcCenter:CGPointMake(radius, radius) , radius: radius - 5.0, startAngle: 0.0, endAngle:  CGFloat(M_PI * 2) , clockwise: true)
        UIColor.whiteColor().set()
        CGContextAddPath(ctx, path.CGPath)
        CGContextSetLineWidth(ctx, 5.0)
        CGContextStrokePath(ctx)
        
    }
    
    
    // 创建指针
    func creatPointImgView() {
        let size = self.bounds.size
        let center = CGPointMake(size.width / 2.0, size.height / 2.0)
        pointImgView = UIImageView(frame: CGRectMake(0, 0, center.x - 12.0, 10))
        pointImgView!.layer.anchorPoint = CGPointMake( 120 / 150.0, 0.5)
        pointImgView!.layer.position = center
        pointImgView?.image = UIImage(named: "箭头")
        pointImgView?.layer.cornerRadius = 5.0
        pointImgView?.layer.masksToBounds = true
        pointImgView!.transform = CGAffineTransformMakeRotation(-startXAxisIncludedAngle)
        self.addSubview(pointImgView!)
        
        let view = UIView.init(frame: CGRectMake(0, 0, 20, 20))
        view.center = CGPointMake(radius, radius)
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        self.addSubview(view)
        
    }

    // 单位和当前值
    func creatShowLabel() {
        unitLabel = UILabel.init(frame: CGRectMake(radius - 50, radius - 40, 100, 25))
        unitLabel.textAlignment = .Center
        unitLabel.font = UIFont.systemFontOfSize(15)
        unitLabel.textColor = UIColor.whiteColor()
        self.addSubview(unitLabel)
        
        currentLabel = UILabel.init(frame: CGRectMake(radius - 50, radius + 20, 100, 25))
        currentLabel.textAlignment = .Center
        currentLabel.font = UIFont.systemFontOfSize(15)
        currentLabel.textColor = UIColor.whiteColor()
        self.addSubview(currentLabel)

    }
    
    
    
    // 旋转角度
    func rotateWithCurrentValue() {
        if maxValue <= 0.0 || currentValue <= 0.0 {
            return
        }
        
        let perValueAngle: CGFloat = CGFloat(startXAxisIncludedAngle * 2 + CGFloat(M_PI)) / maxValue
        
        let rotateAngle: CGFloat = perValueAngle * (currentValue < maxValue ? currentValue : maxValue)
        
        let currentAngle: CGFloat = rotateAngle - startXAxisIncludedAngle
        
        let changeAngle = currentAngle - previousAngle
        previousAngle = currentAngle
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveLinear, animations: {
            
            if changeAngle  > CGFloat(M_PI) || changeAngle <  CGFloat(-M_PI) {
                self.pointImgView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
               
            }else{
                self.pointImgView!.transform = CGAffineTransformMakeRotation(currentAngle)
              
            }
            
        }) { (finished) in
            
            if changeAngle  > CGFloat(M_PI) || changeAngle <  CGFloat(-M_PI) {
                
                UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveLinear, animations:  {
                    self.pointImgView!.transform = CGAffineTransformMakeRotation(currentAngle)
                   
                }) { (finished) in
                    
                }
                
            }
            
            
            
        }
    }
    

    //MARK: - 改变值 -- 外部使用方法
    func changeWithValue(value: CGFloat, maxValue: CGFloat, units: String) {
        
     
       
        let varlueStr = NSString.init(format: "%.0f", value)
        currentLabel.text = varlueStr as String
        
        
        if units != unitLabel.text {
            unitLabel.text = units
        }
        
       
        if maxValue == self.maxValue { // 最大值未改变
            if currentValue != value {
                self.currentValue = value
                self.rotateWithCurrentValue()
            }
            
        }else{
            self.maxValue = maxValue
            self.currentValue = value
            drawScaleValue()
            rotateWithCurrentValue()
        }
        
        
    }
    

}
