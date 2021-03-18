
//
//  VC_Config.swift
//  PITAMS
//
//  Created by admin on 2020/03/31.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit
class VC_Config: UIViewController {
    
    //@IBOutlet weak var tvPicSize: UITextField!
    @IBOutlet weak var tvThVal: UITextField!
    @IBOutlet weak var tvYVal: UITextField!
    @IBOutlet weak var tvXVal: UITextField!
    @IBOutlet weak var flgTh: UISwitch!
    @IBOutlet weak var flgSens: UISwitch!
    //@IBOutlet weak var sldrPicSize: UISlider!
    @IBOutlet weak var sldrTh: UISlider!
    @IBOutlet weak var sldrZ: UISlider!
    @IBOutlet weak var sldrX: UISlider!
    
    var thFlg:Bool = true
    var gyroFlg:Bool = false
    var circleFlg:Bool = false
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Config", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画像サイズ設定
        //sldrPicSize.value = CV.picsizeSldrVal
        //let Str:String = String(Int(round(CV.PIC_X * CV.picsizeSldrVal))) + "×" + String(Int(round(CV.PIC_Y * CV.picsizeSldrVal)))
        //tvPicSize.text = String(Str)
        
        //閾値設定
        flgTh.isOn = CV.THFlg
        tvThVal.text = String(CV.threshold)
        sldrTh.value = Float(CV.threshold)
        
        //ジャイロ設定
        flgSens.isOn = CV.GyroFlg
        switchGyro(flgSens)
        sldrZ.value = CV.magniZ
        tvYVal.text = String(CV.magniZ)
        sldrX.value = CV.magniX
        tvXVal.text = String(CV.magniX)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *),CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13.0, *),CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    
//    @IBAction func tapCancel(_ sender: Any) {
//        self.backView()
//    }
    
    
    @IBAction func tapBack(_ sender: Any) {
        self.backView()
    }
    
    @IBAction func tapSave(_ sender: Any) {
        //値を保存する
        //CV.picsizeSldrVal = round(sldrPicSize.value * 10) / 10
        switchTh(flgTh)
        CV.THFlg = thFlg
        CV.threshold = Int(round(sldrTh.value))
        switchGyro(flgSens)
        CV.GyroFlg = gyroFlg
        CV.magniZ = round(sldrZ.value * 100) / 100 
        CV.magniX = round(sldrX.value * 100) / 100
        self.backView()
    }
    
//    @IBAction func changePicSize(_ sender: Any) {
//        let test:Float = round(sldrPicSize.value * 10) / 10
//        let Str:String = String(Int(round(CV.PIC_X * test))) + "×" + String(Int(round(CV.PIC_Y * test)))
//
//        CV.imgSizeX = Int(round(CV.PIC_X * test))
//        CV.imgSizeY = Int(round(CV.PIC_Y * test))
//
//        tvPicSize.text = String(Str)
//    }
    
    @IBAction func switchTh(_ sender: UISwitch) {
        if(sender.isOn) {
            thFlg = true
            sldrTh.isEnabled = true
        }else {
            thFlg = false
            sldrTh.isEnabled = false
        }
    }
    
    @IBAction func changeTh(_ sender: Any) {
        if !thFlg{
            return
        }
        let test:Float = round(sldrTh.value)
        tvThVal.text = String(test)
    }
    
    @IBAction func switchGyro(_ sender: UISwitch) {
        if(sender.isOn) {
            gyroFlg = true
            sldrX.isEnabled = true
            sldrZ.isEnabled = true

        }else { // 全てオフにする
            gyroFlg = false
            sldrX.isEnabled = false
            sldrZ.isEnabled = false
        }
    }
    
    
    @IBAction func changeZ(_ sender: Any) {
        let test:Float = round(sldrZ.value * 100) / 100
        sldrZ.value = test

        let Str:String = String(test)
        tvYVal.text = String(Str)
    }
    
    @IBAction func changeX(_ sender: Any) {
        let test:Float = round(sldrX.value * 100) / 100
        sldrX.value = test

        let Str:String = String(test)
        tvXVal.text = String(Str)
    }
}

