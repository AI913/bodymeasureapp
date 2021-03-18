//
//  extends.swift
//  PITAMS
//
//  Created by admin on 2019/10/11.
//  Copyright © 2019 frontarc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import AudioToolbox

extension UIViewController {
    //OKのみのメッセージ表示
    // 確認メッセージ表示
    func alert(strMsg: String, strTitle: String = "", handler: @escaping ()->Void) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let dialog = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
        let act1 = UIAlertAction(title: "OK", style: .default) { action in
            handler()
        }
        dialog.addAction(act1)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    // 確認メッセージ表示
    func confirm(strMsg: String, strTitle: String = "", handler: @escaping (Bool)->Void) {
        let dialog = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
        let act1 = UIAlertAction(title: "OK", style: .default) { action in
            handler(true)
        }
        let act2 = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            handler(false)
        }
        dialog.addAction(act1)
        dialog.addAction(act2)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    // 確認メッセージ表示
    func confirm(strMsg: String, strTitle: String = "", strOK: String, strNG:String, handler: @escaping (Bool)->Void) {
        let dialog = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
        let act1 = UIAlertAction(title: strOK, style: .default) { action in
            handler(true)
        }
        let act2 = UIAlertAction(title: strNG, style: .cancel) { action in
            handler(false)
        }
        dialog.addAction(act1)
        dialog.addAction(act2)
        
        self.present(dialog, animated: true, completion: nil)
    }
        
    func backView(){
        if CV.FlgDemo == 2 {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension UIView {
    func GetImage() -> UIImage{
        // キャプチャする範囲を取得.
        let rect = self.bounds
        
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        // 対象のview内の描画をcontextに複写する.
        self.layer.render(in: context)
        
        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // contextを閉じる.
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension UIImage {
    
    func rotatedBy(degree: CGFloat, isCropped: Bool = true) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        var rotatedRect = CGRect(origin: .zero, size: self.size)
        if !isCropped {
            rotatedRect = rotatedRect.applying(CGAffineTransform(rotationAngle: radian))
        }
        UIGraphicsBeginImageContext(rotatedRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    //二値化
    func Threshold(target:Int)->UIImage{
        let imageRef = self.cgImage!
        let data = imageRef.dataProvider!.data
        let buffer = CFDataGetBytePtr(data)!
        
        let threshold = target
        let imageBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: imageRef.height * imageRef.width * 4)
        // 各ピクセルに対し色を割り当てる
        for y in 0..<imageRef.height {
            for x in 0..<imageRef.width {
                // ピクセルの先頭の配列
                let frontPixelIndex = (y * imageRef.width + x) * 4
                let red     = Float(buffer[frontPixelIndex + 0]) / 255.0
                let green   = Float(buffer[frontPixelIndex + 1]) / 255.0
                let blue    = Float(buffer[frontPixelIndex + 2]) / 255.0
                let alpha   = buffer[frontPixelIndex + 3]
                let average = UInt8((red + green + blue) * 255 / 3)
                let binaryValue = average < threshold ? 0 : 255
                imageBytes[frontPixelIndex + 0] = UInt8(binaryValue)
                imageBytes[frontPixelIndex + 1] = UInt8(binaryValue)
                imageBytes[frontPixelIndex + 2] = UInt8(binaryValue)
                imageBytes[frontPixelIndex + 3] = alpha
            }
        }
        
        // 画像処理後のデータから画像を作成
        let resultData = CFDataCreate(nil, imageBytes, imageRef.height * imageRef.width * 4)!
        imageBytes.deallocate()
        let  resultDataProvider = CGDataProvider(data: resultData)!
        let resultImageRef = CGImage(width: imageRef.width,
                                     height: imageRef.height,
                                     bitsPerComponent: imageRef.bitsPerComponent,
                                     bitsPerPixel: imageRef.bitsPerPixel,
                                     bytesPerRow: imageRef.bytesPerRow,
                                     space: imageRef.colorSpace!,
                                     bitmapInfo: imageRef.bitmapInfo,
                                     provider: resultDataProvider,
                                     decode: nil,
                                     shouldInterpolate: imageRef.shouldInterpolate,
                                     intent: imageRef.renderingIntent)!
        let resultImage = UIImage(cgImage: resultImageRef, scale: 1.0, orientation:self.imageOrientation)
        
        
        return resultImage
    }
    
    //高速特殊二値化（白黒画像にのみ適応可能）
    func ThresholdRefine(target:Int)->UIImage{
        let imageRef = self.cgImage!
        let data = imageRef.dataProvider!.data
        let buffer = CFDataGetBytePtr(data)!
        
        let threshold = target
        let imageBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: imageRef.height * imageRef.width * 4)
        // 各ピクセルに対し色を割り当てる
        for y in 0..<imageRef.height {
            for x in 0..<imageRef.width {
                let frontPixelIndex = (y * imageRef.width + x) * 4
                //白黒ならアルファ以外のチャンネルは全部一緒。参照するチャンネルは一つで賄えるはず
                let binaryValue = UInt8(buffer[frontPixelIndex + 0]) < threshold ? 0 : 255
                imageBytes[frontPixelIndex + 0] = UInt8(binaryValue)
                imageBytes[frontPixelIndex + 1] = UInt8(binaryValue)
                imageBytes[frontPixelIndex + 2] = UInt8(binaryValue)
                imageBytes[frontPixelIndex + 3] = UInt8(1.0)
            }
        }
        
        // 画像処理後のデータから画像を作成
        let resultData = CFDataCreate(nil, imageBytes, imageRef.height * imageRef.width * 4)!
        imageBytes.deallocate()
        let  resultDataProvider = CGDataProvider(data: resultData)!
        let resultImageRef = CGImage(width: imageRef.width,
                                     height: imageRef.height,
                                     bitsPerComponent: imageRef.bitsPerComponent,
                                     bitsPerPixel: imageRef.bitsPerPixel,
                                     bytesPerRow: imageRef.bytesPerRow,
                                     space: imageRef.colorSpace!,
                                     bitmapInfo: imageRef.bitmapInfo,
                                     provider: resultDataProvider,
                                     decode: nil,
                                     shouldInterpolate: imageRef.shouldInterpolate,
                                     intent: imageRef.renderingIntent)!
        let resultImage = UIImage(cgImage: resultImageRef, scale: 1.0, orientation:self.imageOrientation)
        
        
        return resultImage
    }
    
    func rgb2GrayScale() -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue),
              let cgImage = cgImage
            else {
                return nil
        }
        
        context.draw(cgImage, in: rect)
        
        guard let image = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: image)
    }
    
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}

// CIImageの拡張
extension CIImage {
    func resizeToSameSize(as anotherImage: CIImage) -> CIImage {
        let size1 = extent.size
        let size2 = anotherImage.extent.size
        let transform = CGAffineTransform(scaleX: size2.width / size1.width, y: size2.height / size1.height)
        return transformed(by: transform)
    }
    
    func createCGImage() -> CGImage {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(self, from: extent) else { fatalError() }
        return cgImage
    }
}

extension String{
    public func isOnly(_ characterSet: CharacterSet) -> Bool {
        return self.trimmingCharacters(in: characterSet).count <= 0
    }
    
    public func isOnlyNumeric() -> Bool {
        return isOnly(.decimalDigits)
    }
    
    public func isOnlyNumericDot() -> Bool {
        return isOnly(CharacterSet(charactersIn: "01234556789."))
    }
    
    public func isOnlyAlphabetNumeric() -> Bool {
        return isOnly(.alphanumerics)
    }
    
    public func isOnly(_ characterSet: CharacterSet, _ additionalString: String) -> Bool {
        var replaceCharacterSet = characterSet
        replaceCharacterSet.insert(charactersIn: additionalString)
        return isOnly(replaceCharacterSet)
    }
}

// ジャイロ用Viewの移動関数
extension UIImageView {
    
    // X方向に平行移動する
    func addX(x: CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x * CV.mCoefficient // 係数をかけて動きの大きさを調整
        self.frame = frame
    }

    // Y方向に平行移動する
    func addY(z: CGFloat) {
        var frame:CGRect = self.frame
        
        frame.origin.y = z * CV.mCoefficient
        self.frame = frame
    }
    
    // ロール回転（風車のようにz軸を中心に回転する）
    func rotate(_ xAngle: CGFloat) {
        //傾けすぎるとviewが消えるのを防ぐ
        if xAngle > 0.9 || xAngle < -0.9{
            return
        }
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        // xAngleの値は-1〜+1に正規化されているため、単位円上の逆三角関数を考える
        rotationAnimation.toValue = acos(xAngle) - (CGFloat.pi / 2) // pi/2[rad]=90°回転させる
        rotationAnimation.duration = 1
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimation.isRemovedOnCompletion = false
        self.layer.add(rotationAnimation, forKey: nil)
    }
    
    // ピッチ回転（x軸を中心に回転する、奥行きの表現）
    func rotatePitch(_ zAngle: CGFloat){
        //傾けすぎるとviewが消えるのを防ぐ
        if zAngle > 0.9 || zAngle < -0.9{
            return
        }
        self.layer.zPosition = self.frame.height/2
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        rotationAnimation.toValue = acos(zAngle) - (CGFloat.pi / 2)
        rotationAnimation.duration = 1
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimation.isRemovedOnCompletion = false
        self.layer.add(rotationAnimation, forKey: nil)
    }
    
    //アウトライン画像と重なっているかを判定
    func judgeOverlap(_ xAngle:CGFloat, _ zAngle:CGFloat)->Bool {
        if (CGFloat(CV.magniX) > xAngle && xAngle > -CGFloat(CV.magniX)) && (CGFloat(CV.magniZ) > zAngle && zAngle > -CGFloat(CV.magniZ)){
            return true
        }else{
            return false
        }
    }
}
