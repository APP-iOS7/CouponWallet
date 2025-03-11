//
//  CaptureManager.swift.swift
//  CouponWallet
//
//  Created by Reimos on 3/9/25.
//

import SwiftUI
import Photos

// UIView 확장을 통해 해당 뷰를 UIImage로 변환 하는 함수 구현
extension UIView {
    func changeUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
func saveCaptureImageToAlbum(_ screenshot: UIImage) {
    UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
    print("스크린샷 저장 성공!!!")
}

