//
//  Gradien.swift
//  baluchon
//
//  Created by laurent aubourg on 19/09/2021.
//
import UIKit

extension UIView{
    func addGradient(gradientColors:[CGColor] ){
        let  newLayer = CAGradientLayer()
        newLayer.colors = gradientColors
        newLayer.frame = self.frame
        self.layer.insertSublayer(newLayer, at: 0)
    }
}
