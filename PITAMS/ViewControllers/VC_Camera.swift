//
//  VC_Camera.swift
//  PITAMS
//
//  Created by admin on 2020/03/23.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

protocol PhotoDelegate {
    func PhotoEnd(ptn:Int, photo:[[UIImage?]], lines:[Int])
}

class VC_Camera: UIViewController,LineDelegate {
    
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice!
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput!
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    //写真撮影後の処理用デリゲート
    var delegate:PhotoDelegate!
    //ガイド画像
    var shadowImage:UIImage!
    //モーションセンサー
    //var MMFlg:Bool
    var MM:CMMotionManager!
    var TargetX:Double!
    var TargetY:Double!
    var TargetZ:Double!
    var xAngle:Double!
    var yAngle:Double!
    
    //二値フラグ
    var THFlg:Bool = true
    //var THTarget:Int = 100
    
    //画像サイズ
    //1440x2560を基準とした倍率
    var PicSize:CGFloat = CGFloat(CV.imgSizeX) / CGFloat(CV.imgSizeX)
    //リサイズ時のサイズ
    var resized_size:CGSize = CGSize(width:0, height:0)
    //モーションセンサの値
    var xm:Double = 0.0
    var xp:Double = 0.0
    var y:Double = 0.0
    
    //画像
    var normalImage:UIImage?
    var ThresholdImage:UIImage?
    
    //ガイド
    //var Pictures:[[UIImage?]] = []
    
    //撮影モード
    //var photoType:Int = -1
    //var nowType:Int = -1
    
    //返却用
    var Lines:[Int] = [-1, -1, -1]
    
    // ジャイロの感度調整用係数
    let coefficient: CGFloat = 30
    //ジャイロ画像の傾き保存用
    var currentDegree:Float = 90
    //ガイドとの重なり判定用
    private var overlapFlg:Bool = false
    
    @IBOutlet weak var circleView:UIView!
    // シャッターボタン
    @IBOutlet weak var btn_Camera: UIButton!
    // ガイド
    @IBOutlet weak var imgShadow: UIImageView!
    //目標円を描画するView
    var drawView:DrawView!
    //ジャイロ角
    @IBOutlet weak var lblX: UILabel!
    @IBOutlet weak var lblY: UILabel!
    //ジャイロ用ビュー
    @IBOutlet weak var motionView:UIImageView!
    
    @IBOutlet weak var lblWide: UIButton!
    @IBOutlet weak var lblSide: UIButton!
    @IBOutlet weak var btnWide: UIButton!
    @IBOutlet weak var btnSide: UIButton!
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Camera", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgShadow.frame = self.view.frame
        imgShadow.contentMode = .scaleAspectFit
        motionView.frame = self.view.frame
        motionView.contentMode = .scaleAspectFit
        imgShadow.addSubview(motionView)
        
        btnWide.titleLabel?.adjustsFontSizeToFitWidth = true
        btnWide.titleLabel?.minimumScaleFactor = 0.7
        
        //カメラの設定が完了した場合にのみカメラを起動する
        if setupCaptureSession(){
            setupPreviewLayer()
            captureSession.startRunning()
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        if let drawView = drawView{
            drawView.removeFromSuperview()
        }
        drawView = DrawView(frame: circleView.bounds)
        circleView.addSubview(drawView)
        drawView.frame = self.view.frame
        drawView.contentMode = .scaleAspectFit
        
        //ジャイロオンの場合motionViewを表示
        if CV.GyroFlg{
            self.motionView?.isHidden = false
        }else{
            self.motionView?.isHidden = true
            self.btn_Camera.isEnabled = true
        }
        
        ChangePhotoType()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //カメラに移動する場合
        if segue.identifier == "MoveToMarker" {
            let vc = segue.destination as! VC_Marker
            vc.delegate = self
            //vc.pictures = Pictures
            //if nowType == CV.PTN_ALL{
                //vc.photoType = CV.nowType
            //}
            //else{
                //vc.photoType = photoType
            //}
        }
    }
    
    //デバッグ用
//    func calculateImageSize() -> CGSize {
//        let imageSize = AVMakeRect(aspectRatio: self.imgShadow.image!.size, insideRect: self.imgShadow.bounds).size
//        return imageSize
//    }
    
    //viewが表示されるたびにセンサと目標円の可視化チェックする
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //デバッグ用
        //print("aspectfit: ", calculateImageSize())
        
        //ジャイロオフの場合は現在角度の表示なし
        if !CV.GyroFlg{
            self.lblX.text = ""
            self.lblY.text = ""
        }
        
        //モーションセンサーの設定
        MM = CMMotionManager()
        if MM.isAccelerometerAvailable {
            //センサー取得感覚
            MM.accelerometerUpdateInterval = CV.MTN_INTERVAL
            MM.startAccelerometerUpdates(to: OperationQueue.main,withHandler:{aData,error in
                //センサーからデータが返ってこないこともある。その場合は一旦スルーする。
                guard let data = aData else{
                    return
                }
                
                //ジャイロオンの場合は人影画像を移動する
                if CV.GyroFlg{
                    
                    //小数点第2位まで求めて四捨五入する
                    self.TargetY = round(data.acceleration.y * CV.MTN_ROUND) / CV.MTN_ROUND
                    self.TargetX = round(data.acceleration.x * CV.MTN_ROUND) / CV.MTN_ROUND
                    self.TargetZ = round(data.acceleration.z * CV.MTN_ROUND) / CV.MTN_ROUND
                    
                    //画面上に表示する
                    self.lblX.text = "X軸：" + String(self.TargetX)
                    self.lblY.text = "Z軸：" + String(self.TargetZ)
                    
                    //画像を水平移動する
                    self.motionView.isHidden = false
                    self.motionView.addX(x: CGFloat(self.TargetX) * self.coefficient)
                    self.motionView.addY(z: CGFloat(self.TargetZ) * self.coefficient)
                    self.motionView.rotate(CGFloat(self.TargetX))
                    self.motionView.rotatePitch(CGFloat(self.TargetZ))
                    
                    //傾きすぎを検知
                    if self.motionView.judgeOverlap(CGFloat(self.TargetX), CGFloat(self.TargetZ)){
                        self.motionView?.isHidden = true
                        self.btn_Camera.isEnabled = true
                    }else{
                        self.motionView?.isHidden = false
                        self.btn_Camera.isEnabled = false
                    }
                }
            })
        }
        //モーションセンサーが利用できない場合はエラーとして画面を戻す
        else{
            self.alert(strMsg: MSG.ERR_CMR_MTN, handler: {
                self.backView()
            })
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopAccelerometer()
    }
    
    //加速度センサをストップ
    func stopAccelerometer(){
        if (MM.isAccelerometerActive) {
            MM.stopAccelerometerUpdates()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // シャッターボタンが押された時のアクション
    @IBAction func tapCamera(_ sender: Any) {
        //モーションセンサーをONにしている場合は傾きをチェックする
        if CV.MMFlg{
            
            //ジャイロオンの場合、傾きチェック
            if CV.GyroFlg && !self.motionView.judgeOverlap(CGFloat(self.TargetX), CGFloat(self.TargetZ)){
                self.alert(strMsg: MSG.ERR_CMR_RTC, handler: {})
                return
            }
        }
        
        btn_Camera.isEnabled = false
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .auto
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        
        settings.isDepthDataDeliveryEnabled = true
        settings.embedsDepthDataInPhoto = true
        settings.isDepthDataFiltered = true
        settings.isPortraitEffectsMatteDeliveryEnabled = true
        settings.embedsPortraitEffectsMatteInPhoto = true
        
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }

    @IBAction func tapBack(_ sender: Any) {
        self.backView()
    }
    @IBAction func tapConfig(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToConfig", sender: nil)
    }
    @IBAction func tapTutorial(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToTutorial", sender: nil)
    }
    
    
    func ChangePhotoType(){
        
        switch CV.nowType {
            case CV.PTN_WIDE:
                imgShadow.image = VC_Main.Pictures[CV.nowType][Util.PIC_FRM]
                motionView.image = VC_Main.Pictures[CV.nowType][Util.PIC_GYR]
                lblWide.setTitleColor(CV.COLOR_SELECT, for: .normal)
//            case CV.PTN_SIDE:
//                imgShadow.image = VC_Main.Pictures[CV.nowType][Util.PIC_FRM]
//                motionView.image = VC_Main.Pictures[CV.nowType][Util.PIC_GYR]
//                lblWide.setTitleColor(CV.COLOR_WAIT, for: .normal)
            default: //異常検出用
                print("Camera: nowType index out of range!")
                lblWide.setTitleColor(CV.COLOR_SELECT, for: .normal)
                return
        }
    }
    
    //Frontのタップ時
    @IBAction func tapLblWide(){
        CV.nowType = CV.PTN_WIDE
        print("taplblWide: nowType", CV.nowType)
        ChangePhotoType()
    }
    
//    func CheckType()->Int{
//        if photoType == CV.PTN_ALL{
//            return nowType
//        }else{
//            return photoType
//        }
//    }
    
    func LineEnd(lines:[Int]){
        print("LineEnd: nowType", CV.nowType)
        switch CV.nowType {
            case CV.PTN_WIDE:
                self.delegate.PhotoEnd(ptn: CV.nowType, photo: VC_Main.Pictures, lines: lines)
                CV.nowType = checkNoPic()
                return
            
            case CV.PTN_SIDE:
                
                if CV.LineFlg{
                    Lines[CV.LINE_W] = lines[CV.LINE_W]
                    Lines[CV.LINE_H] = lines[CV.LINE_H]
                    Lines[CV.LINE_L] = lines[CV.LINE_L]
                }
                
                self.delegate.PhotoEnd(ptn: CV.nowType, photo: VC_Main.Pictures, lines: lines)
                CV.nowType = checkNoPic()
                return
            default:
                //エラー検出用に何かする
                print("LineEnd: phototype index out of range")
                return 
        }
    }
    
    func checkNoPic()->Int{
        for (idx,data) in VC_Main.Pictures.enumerated(){
            if data[Util.PIC_TGT] == nil{
                print("idx is ", idx)
                return idx
            }
        }
        self.backView()
        return CV.PTN_ALL
    }
}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension VC_Camera: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let originalImageData = photo.fileDataRepresentation()
        {
            normalImage = UIImage(data: originalImageData)!
            let originalImage = normalImage?.cgImage
            let originalCiImage = CIImage(cgImage: originalImage!)
            
            //顔が認識できていない場合はその後の処理が不可能のためエラーとする
            if photo.portraitEffectsMatte == nil {
                self.alert(strMsg: MSG.ERR_CMR_RST, handler: {
                    self.btn_Camera.isEnabled = true
                })
                return
            }
            
            //切り抜き処理
            let maskImage:CIImage? = CIImage(portaitEffectsMatte: photo.portraitEffectsMatte!)!.resizeToSameSize(as: originalCiImage)
            
            //一度CGImageを経由しなければなぜか変換されず
            let context = CIContext()
            
            //白黒イメージ作成
            let screenImage:UIImage = UIImage(cgImage: context.createCGImage(maskImage!, from: maskImage!.extent)!, scale: 1.0, orientation: UIImage.Orientation.right)
            
            
            ThresholdImage = screenImage
            
            
            //オフラインデモモードの時だけ画像をフォトライブラリに保存
            if CV.FlgDemo == 2{
                if CV.THFlg{
                    //二値化、画像保存
                    ThresholdImage = screenImage.ThresholdRefine(target: CV.threshold)
                    UIImageWriteToSavedPhotosAlbum(ThresholdImage!.scaleImage(scaleSize: PicSize), self, nil, nil)
                }
                //色付き画像を保存
                UIImageWriteToSavedPhotosAlbum(normalImage!.scaleImage(scaleSize: PicSize), self, nil, nil)
            }
            
            btn_Camera.isEnabled = true
            
            VC_Main.Pictures[CV.nowType][Util.PIC_TGT] = ThresholdImage // -1,0
            VC_Main.Pictures[CV.nowType][Util.PIC_DMY] = normalImage //-1,0
            
            self.performSegue(withIdentifier: "MoveToMarker", sender: nil)
        }
        else{
            self.alert(strMsg: MSG.ERR_CMR_MISS, handler: {})
            return
        }
    }
}

//MARK: カメラ設定メソッド
extension VC_Camera{
    // カメラの画質の設定
    func setupCaptureSession()->Bool {
        do{
            captureSession.beginConfiguration()
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
            
            //X系で試して無理だったら対策が必要
            //iPhone11かXかでデバイス名が異なる
            if #available(iOS 13.0, *) {
                currentDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
                if currentDevice == nil {
                    currentDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
                }
            } else {
                //デュアルカメラが使えない場合
                print("no dual camera")
            }
            //デュアルカメラが対応していない場合、距離が取得できないのでエラー
            if currentDevice == nil{
                self.alert(strMsg: MSG.ERR_CMR_SNR, handler: {
                    self.backView()
                })
                return false
            }
            
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(self.photoOutput!)
            //
            captureSession.commitConfiguration()
            
            // メモ:commitConfiguration後でないとエラー？
            photoOutput.isDepthDataDeliveryEnabled = true
            photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
            
            return true
        }
        catch{
            //その他の致命的なエラー。上記で基本的なエラーは潰してるので基本的にここには来ない
            print(error)
            self.alert(strMsg: MSG.ERR_FATAL, handler: {
                print("Camera: fatal error: backview")
                self.backView()
            })
            return false
        }
    }

    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        //self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        //レイヤーサイズを画面と同じに
        self.cameraPreviewLayer?.frame = view.frame
        //画面に貼り付ける
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    func resized(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

class DrawView: UIView {

    var oval:UIBezierPath?
    var fm:CGRect?

    override init(frame: CGRect) {
        super.init(frame: frame);
        fm = frame
        self.backgroundColor = UIColor.clear;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //目標円マーカーを描画
    override func draw(_ rect: CGRect) {
        let width = self.frame.width * CGFloat(CV.magniX)
        let height = self.bounds.height * CGFloat(CV.magniZ)

        if let fm = fm {
        oval = UIBezierPath(
            ovalIn: CGRect(origin: CGPoint(x:fm.midX - width/2 ,y:fm.midY - height/2/2),
                           size: CGSize(width: width,
                                        height: height/2)))
        }
    }
}
