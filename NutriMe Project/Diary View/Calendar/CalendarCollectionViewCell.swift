//
//  CalendarCollectionViewCell.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 09/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var circle: UIView!
    
    func DrawCircle() {
            
        let circleCenter = circle.center
        
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: (circle.bounds.width/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
            
        let CircleLayer = CAShapeLayer()
        CircleLayer.path = circlePath.cgPath
        CircleLayer.strokeColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
        CircleLayer.lineWidth = 2
        CircleLayer.strokeEnd = 0
        CircleLayer.fillColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
        CircleLayer.lineCap = CAShapeLayerLineCap.round
        circle.layer.addSublayer(CircleLayer)
        circle.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func DrawGreyCircle() {
        let circleCenter = circle.center
            
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: (circle.bounds.width/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
        
        let CircleLayer = CAShapeLayer()
        CircleLayer.path = circlePath.cgPath
        CircleLayer.strokeColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        CircleLayer.lineWidth = 2
        CircleLayer.strokeEnd = 0
        CircleLayer.fillColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        CircleLayer.lineCap = CAShapeLayerLineCap.round
        circle.layer.addSublayer(CircleLayer)
        circle.layer.backgroundColor = UIColor.clear.cgColor
            
    }
}
