//
//  VC_Marker.swift
//  lineTest
//
//  Created by admin on 2020/03/06.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit

protocol LineDelegate {
    func LineEnd(lines:[Int])
}

class VC_Marker: UIViewController {
    @IBOutlet weak var vBack: UIView!       //最背面
    @IBOutlet weak var imgPic: UIImageView! //画像設置箇所
    @IBOutlet weak var drawView: UIImageView!   //線を書くView
    @IBOutlet weak var vAreaTop: UIView!    //頭ライン
    @IBOutlet weak var vAreaWaist: UIView!  //腰ライン
    @IBOutlet weak var vAreaHip: UIView!    //尻ライン
    @IBOutlet weak var vAreaLeg: UIView!    //足ライン
    @IBOutlet weak var vAreaBottom: UIView! //地ライン
    @IBOutlet weak var imgSub: UIImageView!
    @IBOutlet weak var imgLineButton: UIButton!
    @IBOutlet weak var lengthLabel: UILabel!    //線の長さ（身長の割合から算出した)
    @IBOutlet weak var label_1: UIButton!
    @IBOutlet weak var instructLabel: UILabel!  //指示の表示
    @IBOutlet weak var erase: UIButton! //描いた線を消すボトン
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var shoulderLabel: UILabel!
    @IBOutlet weak var chestLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var waistLabel: UILabel!
    @IBAction func reset(_ sender: Any) {
        drawView.image = nil
        prevImage = nil
        lengthLabel.text = "0.0cm"
    }
    
    var delegate:LineDelegate!
    
    //var pictures:[[UIImage?]] = []
    //var photoType:Int = 0
    var LineFlg:Bool = true
    var viewFlg:Bool = true
    var measurements:Bool = false
    var lineLocked:Bool = false
    var whatever:Measurements? = nil
    
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Marker", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //ライン当たり判定の透明化
        vAreaTop.isOpaque = false
        vAreaTop.backgroundColor = .clear
        vAreaWaist.isOpaque = false
        vAreaWaist.backgroundColor = .clear
        vAreaHip.isOpaque = false
        vAreaHip.backgroundColor = .clear
        vAreaLeg.isOpaque = false
        vAreaLeg.backgroundColor = .clear
        vAreaBottom.isOpaque = false
        vAreaBottom.backgroundColor = .clear
        instructLabel.isHidden = false
        erase.isHidden = true
        lengthLabel.isHidden = true
        imgLineButton.isHidden = true
        heightLabel.isHidden = true
        shoulderLabel.isHidden = true
        chestLabel.isHidden = true
        bodyLabel.isHidden = true
        waistLabel.isHidden = true
        
        //ライン非表示の場合、画面切り替えのたびにライン非表示を解除
        //if !CV.LineFlg{
            //tapFlg(self.imgLineButton!)
        //}
        
        //tapFlg(self.imgLineButton!)
        ChangeLine()
        ChangeView()
    }
    
   override func viewWillDisappear(_ animated: Bool) {
    
        if checkNoPic() == CV.PTN_ALL{
            guard let camera = self.presentingViewController as? VC_Camera else {
                return
            }

            camera.dismiss(animated: true, completion: nil)
            camera.tapBack(UIButton())
            //camera.backView()
        }
        
        if #available(iOS 13.0, *), CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    func checkNoPic()->Int{
        for (idx,data) in VC_Main.Pictures.enumerated(){
            if data[Util.PIC_TGT] == nil{
                return idx
            }
        }
        return CV.PTN_ALL
    }

    //パン（スライド）イベント
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        if lineLocked == false {
            //反応したのがViewでなければ処理しない
            guard let target = sender.view else {
                return
            }
            
            // translationInViewが返す値は、パンが始まってからの蓄積された値となる
            let p = sender.translation(in: self.view)
            
            // 移動先座標の算出
            let moved = CGPoint(x: target.center.x, y: target.center.y + p.y)
            //移動
            target.center = moved
            
            //移動量のリセット
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @IBAction func tapBack(_ sender: Any) {
        VC_Main.Pictures[CV.nowType][Util.PIC_TGT] = nil
        VC_Main.Pictures[CV.nowType][Util.PIC_DMY] = nil
        self.backView()
    }
    
    @IBAction func tapFlg(_ sender: Any) {
        CV.LineFlg = !CV.LineFlg
        if CV.LineFlg{
            imgLineButton.setImage(UIImage(named: "btn_line"), for: .normal)        }
        else{
            imgLineButton.setImage(UIImage(named: "btn_line_active"), for: .normal)
        }
        ChangeLine()
    }

    // Binaryに入れ替える
    @IBAction func tapViewChange(_ sender: Any) {
        viewFlg = !viewFlg
        ChangeView()
    }
    
    //メインサブビューの入れ替え
    func ChangeView(){
        if viewFlg{
            imgPic.image = VC_Main.Pictures[CV.nowType][Util.PIC_DMY]
            imgSub.image = VC_Main.Pictures[CV.nowType][Util.PIC_TGT]
        }
        else{
            imgPic.image = VC_Main.Pictures[CV.nowType][Util.PIC_TGT]
            imgSub.image = VC_Main.Pictures[CV.nowType][Util.PIC_DMY]
        }
    }
    
    @IBAction func tapOK(_ sender: Any) {
            if instructLabel.text != "線を頭の上と足元に移す" {
                if instructLabel.isHidden == false {
                    guard prevImage != nil else {
                        
                        self.alert(strMsg: MSG.ERR_LINE_NIL, handler: {})
                        return
                    }
                }
            }
            drawView.image = nil
            prevImage = nil
            lengthLabel.text = "0.0cm"
            if instructLabel.text == "線を頭の上と足元に移す"{
                measurements = true
                lineLocked = true
                lengthLabel.isHidden = false
                lengthLabel.text = "0.0cm"
                instructLabel.text = "肩幅の線を描く"
                erase.isHidden = false
                print(getTwoLineDistance())
            } else if instructLabel.text == "肩幅の線を描く" {
                RESDATA.shoulder = round((getLength())*10)/10
                instructLabel.text = "身幅の線を描く"
            } else if instructLabel.text == "身幅の線を描く" {
                RESDATA.chest = round((getLength())*10)/10
                instructLabel.text = "着丈の線を描く"
            } else if instructLabel.text == "着丈の線を描く" {
                RESDATA.body = round((getLength())*10)/10
                instructLabel.text = "ウエストの線を描く"
            } else if instructLabel.text == "ウエストの線を描く" {
                RESDATA.waist = round((getLength())*10)/10
                erase.isHidden = true
                
                lengthLabel.isHidden = true
                
                // Show all the measurements
                heightLabel.isHidden = false
                shoulderLabel.isHidden = false
                chestLabel.isHidden = false
                bodyLabel.isHidden = false
                waistLabel.isHidden = false
                
                label_1.setTitle("Measurements", for: .normal)
                instructLabel.text = ""
                instructLabel.isHidden = true
                heightLabel.text = "身長："+"\(RESDATA.empRes?.height ?? 0)" + "cm"
                shoulderLabel.text = "肩幅："+"\(RESDATA.shoulder ?? 0)" + "cm"
                chestLabel.text = "身幅："+"\(RESDATA.chest ?? 0)" + "cm"
                bodyLabel.text = "着丈："+"\(RESDATA.body ?? 0)" + "cm"
                waistLabel.text = "ウエスト："+"\(RESDATA.waist ?? 0)" + "cm"
                if CV.LineFlg{
                    self.delegate.LineEnd(
                        lines: [
                            Int(vAreaWaist.center.y),
                            Int(vAreaHip.center.y),
                            Int(vAreaLeg.center.y)
                        ]
                    )
                }
            }else{
                self.backView()
                self.backView()
                self.backView()
            }
    }
    
    @IBAction func tapConfig(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToConfig", sender: nil)
    }
    
    @IBAction func tapTutorial(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToTutorial", sender: nil)
    }
    
    func ChangeLine(){
        //ライン表示する場合
        if CV.LineFlg {
            switch CV.nowType {
            case CV.PTN_WIDE:
                vAreaTop.isHidden = false
                vAreaBottom.isHidden = false
                //常に何も表示しない
                vAreaWaist.isHidden = true
                vAreaHip.isHidden = true
                vAreaLeg.isHidden = true
                imgLineButton.isHidden = true
                label_1.setTitle("Front", for: .normal)
                imgLineButton.setImage(UIImage(named: "btn_line_active"), for: .normal)
                return
            default:
                return
            }
        }
        else{
            //ラインを表示しない場合
            vAreaTop.isHidden = true
            vAreaWaist.isHidden = true
            vAreaHip.isHidden = true
            vAreaLeg.isHidden = true
            vAreaBottom.isHidden = true
            
            switch CV.nowType {
            case CV.PTN_WIDE:
                //常に何も表示しない
                imgLineButton.isHidden = true // ボタンを表示しない
                label_1.setTitle("Front", for: .normal)
                imgLineButton.setImage(UIImage(named: "btn_line"), for: .normal)
                return
            default:
                return
            }
        }
    }
    
    /// UIBezierPath
    private var bezierPath: UIBezierPath!

    var startPoint = CGPoint.zero
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var startTouch: CGPoint?
    var secondTouch: CGPoint?
    var currentContext: CGContext?
    var prevImage: UIImage?
    
    /// 描画先Image
    private var lastDrawImage: UIImage!

    /// タッチした座標リスト
    private var touchPoints : [CGPoint]!

    func draw(_ rect: CGRect) {
        lastDrawImage?.draw(at: CGPoint.zero)
        UIColor.brown.setStroke()
        bezierPath.stroke()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard instructLabel.isHidden != true else {
            return
        }
        
        guard prevImage == nil else {
            self.alert(strMsg: MSG.ERR_REP, handler: {})
            return
        }
        
        if measurements == true {

            
            let touch = touches.first
            startTouch = touch?.location(in: drawView)

        } else {
            print("measurements is not false")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard instructLabel.isHidden != true else {
            return
        }
        if measurements == true {

            for touch in touches{
                secondTouch = touch.location(in: drawView)
                
                if(self.currentContext == nil) {
                    UIGraphicsBeginImageContext(drawView.frame.size)
                    self.currentContext = UIGraphicsGetCurrentContext()
                }else {
                    self.currentContext?.clear(CGRect(x: 0, y: 0, width: drawView.frame.width, height: drawView.frame.height))
                }
                
                self.prevImage?.draw(in: self.drawView.bounds)
                
                let bezier = UIBezierPath()
                
                bezier.move(to: startTouch!)
                bezier.addLine(to: secondTouch!)
                bezier.close()
                
                UIColor.red.set()
                
                self.currentContext?.setLineWidth(4)
                self.currentContext?.addPath(bezier.cgPath)
                self.currentContext?.strokePath()
                let img2 = self.currentContext?.makeImage()
                drawView.image = UIImage.init(cgImage: img2!)
                lengthLabel.text = "\(round((getLength())*10)/10)" + "cm"
            }
            
        }
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard instructLabel.isHidden != true else {
            return
        }
        if measurements == true {

            self.currentContext = nil
            self.prevImage = self.drawView.image
        }
    }

    
    /// UIImageへの描画処理
    /// - Returns: お絵かきしたUIImage
    private func snapShot() -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        lastDrawImage?.draw(at: CGPoint.zero)
        UIColor.brown.setStroke()
        bezierPath.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    /// 始点〜終点の二点間の距離を取得
    /// - Returns: 二点間の距離
    public func getTwoPointDistance() -> CGFloat {


        let sPos = startTouch!
        let ePos = secondTouch!
        
        return sqrt((ePos.x - sPos.x) * (ePos.x - sPos.x) + (ePos.y - sPos.y) * (ePos.y - sPos.y))
    }
    
    public func getLength() -> CGFloat {
        guard RESDATA.empRes != nil else {
            self.alert(strMsg: MSG.ERR_DAT_NIL, handler:{
                self.backView()
                self.backView()
            })
            print("No saved data yet")
            return 0.0
        }
    
        print(RESDATA.empRes!.height!)
        
        return (CGFloat(RESDATA.empRes!.height!)/(getTwoLineDistance())) * getTwoPointDistance()
    }
    
    // Height of the person in the picture (in pixels)
    public func getTwoLineDistance() -> CGFloat {
        return vAreaBottom.frame.maxY - vAreaTop.frame.minY
    }
    
    
}
