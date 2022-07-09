//
//  RoundButton.swift
//  park.ly
//
//  Created by Julian Worden on 7/8/22.
//

import UIKit

class RoundButton: UIButton {
    convenience init(image: UIImage, cornerRadius: CGFloat, backgroundColor: UIColor) {
        self.init()
        self.setImage(image, for: .normal)
        self.tintColor = UIColor(red: 75/255, green: 74/255, blue: 74/255, alpha: 1.0)
        self.backgroundColor = backgroundColor

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .large)
        self.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)

        self.layer.cornerRadius = cornerRadius
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }
}
