import UIKit
import FirebaseDatabase
import SwiftUI

///이미지 크기 변환 해주는것
extension UIImage {
    func resize()-> UIImage{
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { context in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return resizedImage
    }
}
<<<<<<< HEAD:Cocktail/Cocktail/Extension.swift
=======

>>>>>>> 2ecc2de406e4581ffbe821fc94b01b06bf1c86ad:Cocktail/Cocktail/GlobalFunction.swift
