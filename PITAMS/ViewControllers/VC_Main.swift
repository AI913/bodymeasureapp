//
//  VC_Main.swift
//  PITAMS
//
//  Created by admin on 2020/03/24.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit

protocol httpUploadDelegate: class {
    func onSuccess() -> Void
    func onFailed(msg: String, retryFlg:Bool) -> Void
}

class VC_Main: UIViewController,PhotoDelegate,YesNoDelegate,InputDelegate,httpUploadDelegate {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblComName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblShoulder: UILabel!
    @IBOutlet weak var lblWaist: UILabel!
    @IBOutlet weak var lblChest: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var ImageViews: UIView!
    @IBOutlet weak var imgWide: UIButton!
    @IBOutlet weak var imgCheckText: UIImageView!
    @IBOutlet weak var imgCheckPic: UIImageView!
    @IBOutlet weak var imgCheckMeasurements: UIImageView!
    @IBOutlet weak var imgSendBtn: UIButton!
    @IBOutlet weak var imgTutorialBtn: UIButton!
    @IBOutlet weak var imgClearBtn: UIButton!
    @IBOutlet weak var imgConfig: UIButton!
    
    var SelectPic:Int = 0
    //var PhotoType:Int = -1
    static var Pictures:[[UIImage?]] = []
    var Lines:[Int] = [-1, -1, -1]
    var DialogFlg:Int = 0
    var DialogMessage:[String] = ["データと画像をクリアしますか？", "データを送信しますか？"]
    var SendFlg:Bool = false
    //private var vc: VC_Camera =
    //1440x2560を基準とした倍率
    //var PicRatio:CGFloat = CGFloat(CV.imgSizeX) / CGFloat(CV.PIC_X)
    
    func initView(){
        CV.activityIndicatorView.center = view.center
        CV.activityIndicatorView.style = .whiteLarge
        CV.activityIndicatorView.color = .white
        CV.activityIndicatorView.hidesWhenStopped = true
        view.addSubview(CV.activityIndicatorView)
        //let overlay = UIView()
        //overlay.center = view.center
        //view.addSubview(overlay)
        //overlay.addSubview(CV.activityIndicatorView)
    }
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Main", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //イメージの準備
        VC_Main.Pictures = Util.PicInit()
        Util.uDelegate = self
        //initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }

        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        showData()
        
        imgWide.imageView?.contentMode = .scaleAspectFit
        imgWide.contentHorizontalAlignment = .fill
        imgWide.contentVerticalAlignment = .fill
        
        
        imgSendBtn.imageView?.contentMode = .scaleAspectFit
        imgSendBtn.contentHorizontalAlignment = .fill
        imgSendBtn.contentVerticalAlignment = .fill
        imgTutorialBtn.imageView?.contentMode = .scaleAspectFit
        imgTutorialBtn.contentHorizontalAlignment = .fill
        imgTutorialBtn.contentVerticalAlignment = .fill
        imgClearBtn.imageView?.contentMode = .scaleAspectFit
        imgClearBtn.contentHorizontalAlignment = .fill
        imgClearBtn.contentVerticalAlignment = .fill
        
        statusCheck()
    }
    
    func showData(){
        lblComName.text = RESDATA.loginRes?.company_name ?? " -"
        lblDate.text = " " + Util.GetNowDate()
        lblNumber.text = RESDATA.employee_id ?? " -" 
        if let height = RESDATA.empRes?.height{
            lblHeight.text = NSString(format: "%.1f", Double(height)) as String + "cm"
        }else{
            lblHeight.text = " -"
        }
        lblUserName.text = (RESDATA.empRes?.last_name ?? " -") + " " + (RESDATA.empRes?.first_name ?? "")
        if RESDATA.empRes?.gender == 0{
            lblGender.text = "男性"
        }else if RESDATA.empRes?.gender == 1{
            lblGender.text = "女性"
        }else{
            lblGender.text = " -"
        }
        if let shoulder = RESDATA.shoulder{
            lblShoulder.text = NSString(format: "%.1f", Double(shoulder)) as String + "cm"
        }else{
            lblShoulder.text = " -"
        }
        if let waist = RESDATA.waist{
            lblWaist.text = NSString(format: "%.1f", Double(waist)) as String + "cm"
        }else{
            lblWaist.text = " -"
        }
        if let body = RESDATA.body{
            lblBody.text = NSString(format: "%.1f", Double(body)) as String + "cm"
        }else{
            lblBody.text = " -"
        }
        if let chest = RESDATA.chest{
            lblChest.text = NSString(format: "%.1f", Double(chest)) as String + "cm"
        }else{
            lblChest.text = " -"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //カメラに移動する場合
        if segue.identifier == "MoveToCamera" {
            let vc = segue.destination as! VC_Camera
            vc.delegate = self
            //CV.nowType = PhotoType
            //vc.Pictures = VC_Main.Pictures
        }
        else if segue.identifier == "MoveToDialog"{
            let vc = segue.destination as! VC_YesNoDIalog
            vc.delegate = self
            vc.msg = DialogMessage[DialogFlg]
        }
        else if segue.identifier == "MoveToInput"{
            let vc = segue.destination as! VC_Input
            vc.delegate = self
        }
    }
    
    //コンフィグボタンタップ
    @IBAction func tapConfig(_ sender: Any) {
        imgConfig.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.imgConfig.isEnabled = true
        }
        self.performSegue(withIdentifier: "MoveToConfig", sender: nil)
    }
    //入力ボタンタップ
    @IBAction func tapInput(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToInput", sender: nil)
    }
    
    //撮影ボタンタップ
    @IBAction func tapShoot(_ sender: Any) {
        guard RESDATA.empRes != nil else {
            self.alert(strMsg: MSG.ERR_DAT_NIL, handler: {})
            return
        }
        for (idx,data) in VC_Main.Pictures.enumerated(){
            if data[Util.PIC_TGT] == nil{
                CV.nowType = idx
                self.performSegue(withIdentifier: "MoveToCamera", sender: nil)
                return
            }
        }
        // 全て撮影済みの場合、正面撮影に戻る
        CV.nowType = CV.PTN_WIDE
        self.performSegue(withIdentifier: "MoveToCamera", sender: nil)
        return
    }
    
    //画像正面（開き）タップ
    @IBAction func tapWide(_ sender: Any) {
        guard RESDATA.empRes != nil else {
            self.alert(strMsg: MSG.ERR_DAT_NIL, handler: {})
            return
        }
        imgWide.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.imgWide.isEnabled = true
        }
        CV.nowType = CV.PTN_WIDE
        self.performSegue(withIdentifier: "MoveToCamera", sender: nil)
    }
    
    //削除ボタンタップ
    @IBAction func tapClear(_ sender: Any) {
        DialogFlg = 0
        self.performSegue(withIdentifier: "MoveToDialog", sender: nil)
    }
    //送信ボタン
    @IBAction func tapSend(_ sender: Any) {
        if SendFlg{
            DialogFlg = 1
            self.performSegue(withIdentifier: "MoveToDialog", sender: nil)
        }
        return
    }
    //チュートリアルボタン
    @IBAction func tapTutorial(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToTutorial", sender: nil)
    }
    
    func checkNoPic()->Int{
        for (idx,data) in VC_Main.Pictures.enumerated(){
            if data[Util.PIC_TGT] == nil{
                return idx
            }
        }
        self.backView()
        return CV.PTN_ALL
    }
    
    //画像の移動
    func MoveImages(flg:Bool){
        if flg{
            if SelectPic == CV.PTN_WIDE{
                return
            }
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseIn], animations: {
                self.ImageViews.center.x += (self.imgWide.frame.width + 10)
            }, completion: nil)
            SelectPic-=1
        }
        else{
            if SelectPic == CV.PTN_SIDE{
                return
            }
            UIView.animate(withDuration: 0.15, delay: 0.0, options:[.curveEaseIn], animations: {
                self.ImageViews.center.x -= (self.imgWide.frame.width + 10)
            }, completion: nil)
            SelectPic+=1
        }
    }
    
    func statusCheck(){
        //テキスト入力チェック：デモ版ではとりあえずOKとする
        var flgInput:Bool = false
        
        if dataSaved(){
            flgInput = true
            imgCheckText.image = UIImage(named: "check_active")
        }else{
            imgCheckText.image = UIImage(named: "check")
        }
        
        //画像チェック：何もない場合はcheck、１枚〜２枚ならw、３枚揃っていればactive
        var flgPic:Int = 0
        if VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_TGT] != nil{
            flgPic+=1
        }
        if VC_Main.Pictures[CV.PTN_SIDE][Util.PIC_TGT] != nil{
            flgPic+=1
        }
        switch flgPic {
        case 0:
            imgCheckPic.image = UIImage(named: "check")
        case 1:
            imgCheckPic.image = UIImage(named: "check_w")
        case 2:
            imgCheckPic.image = UIImage(named: "check_w_active")
        default:
            //エラー判別処理
            print("flgPic index out of range")
            return
        }
        
        //両方OKでSendボタンを解放する
        if flgPic == 2 && flgInput == true{
            SendFlg = true
            imgSendBtn.setImage(UIImage(named:"footer_save_active"), for: .normal)
        }
        else{
            SendFlg = false
            imgSendBtn.setImage(UIImage(named:"footer_save"), for: .normal)
        }
        
        if measurementsSaved(){
            flgInput = true
            imgCheckMeasurements.image = UIImage(named: "check_active")
        }else{
            imgCheckMeasurements.image = UIImage(named: "check")
        }
    }
    
    func ClearData(){
        //入力値の消去 -> TODO:RESDATAの中身を消す
        
        RESDATA.employee_id = nil
        RESDATA.empRes = nil
        RESDATA.uploadRes = nil
        
        //製品版ではラベルの表示も削除
        //ラインの削除
        Lines = [-1, -1, -1]
        //画像の削除
        imgWide.setImage(VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_DEF], for: .normal)
        
        //撮影画像の削除
        VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_TGT] = nil
        VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_DMY] = nil
        VC_Main.Pictures[CV.PTN_SIDE][Util.PIC_TGT] = nil
        VC_Main.Pictures[CV.PTN_SIDE][Util.PIC_DMY] = nil
        
        statusCheck()
    }
    
    func PhotoEnd(ptn: Int, photo: [[UIImage?]], lines:[Int]) {
        switch ptn {
        case CV.PTN_ALL:
            VC_Main.Pictures = photo
            imgWide.setImage(VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_TGT], for: .normal)
            
        case CV.PTN_WIDE:
            VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_TGT] = photo[CV.PTN_WIDE][Util.PIC_TGT]
            imgWide.setImage(VC_Main.Pictures[CV.PTN_WIDE][Util.PIC_TGT], for: .normal)
        case CV.PTN_SIDE:
            VC_Main.Pictures[CV.PTN_SIDE][Util.PIC_TGT] = photo[CV.PTN_SIDE][Util.PIC_TGT]
            
            Lines[CV.LINE_W] = lines[CV.LINE_W]
            Lines[CV.LINE_H] = lines[CV.LINE_H]
            Lines[CV.LINE_L] = lines[CV.LINE_L]
        default:
            //エラー検出用に何かする
            return
        }
        statusCheck()
    }
    
    func DialogEnd(result: Bool) {
        if DialogFlg == 0 {
            //削除
            if result{
                ClearData()
                showData()
            }
        }
        else{
            //送信
            if result{
                sendData()
            }
        }
        return
    }
    
    func inputEnd() {
        statusCheck()
        return
    }
    
    //データを送信する
    func sendData(){
        
        var json:Data = Data()
        //インジケータを設定
        initView()
        
        //画像変換
        var datas:[String] = []
        if !img2Base64(datas: &datas){
            self.alert(strMsg: MSG.ERR_FATAL, handler: {
            })
            return
        }
        
        //入力データが保存されているかチェック
        if !dataSaved(){
            self.alert(strMsg: MSG.ALT_HAS_NODATA, handler: {
            })
            return
        }
        
        //JSON形式にエンコードしてPOSTする
        if data2Json(datas: datas, json: &json){
            
            if CV.FlgDemo == 2{
                Util.demoPostHttp(obj: self, method: #function)
            }else{
                //POST
                if Util.connectionFlg {
                    //インターネット接続がある場合、POSTする
                    print("接続")
                    Util.PostHttp(obj: self, method: #function, stUrl: CV.uploadUrl, params: json, fn: { data in DispatchQueue.main.async {
                        }
                    })
                    
                } else {
                    print("接続がありません")
                    //接続がない場合、強制的に失敗させる
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        print("インジケータ消します:main:1")
                        CV.activityIndicatorView.stopAnimating()
                    })
                    self.onFailed(msg: MSG.ALT_RTRY, retryFlg:true)
                }
            }
        }else{
            self.alert(strMsg: MSG.ERR_FATAL, handler: {
                self.backView()
            })
        }
    }
    
    //func testImgBase64(){
        //img = UIImage()
    //}
    
    func img2Base64(datas: inout [String])->Bool{
        //画像をbase64変換する
        for i in 0..<2{
            
            if let img = VC_Main.Pictures[i][Util.PIC_TGT]{
                //リサイズして縦向きにする
                let PicSize:CGFloat = CGFloat(CV.imgSizeX) / CGFloat(img.size.width)
                let resizedSize = CGSize(width: img.size.width * PicSize, height: img.size.height * PicSize)
                
                UIGraphicsBeginImageContextWithOptions(resizedSize, false, 1.0)
                img.draw(in: CGRect(origin: CGPoint.zero, size: resizedSize))
                let imageWithOrt:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                guard let im_ort = imageWithOrt.jpegData(compressionQuality: 1.0) as NSData? else{
                    return false
                }
                
                guard let base64str = im_ort.base64EncodedString(options: .lineLength64Characters) as String? else {
                    return false
                }
                datas.append(base64str)
            }
        }
        return true
    }
    
    func dataSaved()->Bool{
        //データ入力チェック
        
        if nil == RESDATA.empRes?.first_name{
            print("first_name is empty")
            return false
        }
        
        if nil == RESDATA.empRes?.last_name{
            print("last_name is empty")
            return false
        }
        
        if nil == RESDATA.empRes?.size_feel{
            print("size_feel is empty")
            return false
        }

        if nil == RESDATA.empRes?.height{
            print("height is empty")
            return false
        }

        if nil == RESDATA.empRes?.weight{
            print("weight is empty")
            return false
        }

        if nil == RESDATA.empRes?.age{
            print("age is empty")
            return false
        }
        
        return true
    }
    
    func measurementsSaved()->Bool {
        if nil == RESDATA.shoulder{
            print("first_name is empty")
            return false
        }
        
        if nil == RESDATA.chest{
            print("last_name is empty")
            return false
        }
        
        if nil == RESDATA.waist{
            print("size_feel is empty")
            return false
        }

        if nil == RESDATA.body{
            print("height is empty")
            return false
        }
        return true
    }
    
    func data2Json(datas:[String], json: inout Data)->Bool{
        let encoder = JSONEncoder()
        
        //TODO:オプショナル項目の処理
        let upinfo = UploadReq(
            company_id: RESDATA.lodinReq!.company_id, 
            employee_id: RESDATA.employee_id!,
            images: datas,
            last_name: RESDATA.empRes!.last_name,
            first_name: RESDATA.empRes!.first_name,
            size_feel: RESDATA.empRes!.size_feel!,
            height: RESDATA.empRes!.height!,
            weight: RESDATA.empRes!.weight!,
            age: RESDATA.empRes!.age!,
            gender: RESDATA.empRes!.gender!,
            //ここからオプショナル項目
            waist: (Lines[0] == -1) ? nil:Lines[0],
            hip: (Lines[1] == -1) ? nil:Lines[1],
            hem: (Lines[2] == -1) ? nil:Lines[2]
        )
        
        
        do {
            json = try encoder.encode(upinfo)
            return true
        }catch{
            //デコードエラー
            print("json decode error: VC_Input")
            return false
        }
    }
    
    func onSuccess() {
        
        DispatchQueue.main.async(execute: {
            print("インジケータ消します:main:2")
            CV.activityIndicatorView.stopAnimating()
        })
        
        self.alert(strMsg: MSG.PRG_COMPLATE, handler: {
            self.ClearData()
            self.showData()
        })
        return
    }
    
    func onFailed(msg: String, retryFlg:Bool) {
        
        DispatchQueue.main.async(execute: {
            print("インジケータ消します:main:3")
            CV.activityIndicatorView.stopAnimating()
        })
        
        //リトライする場合
        if retryFlg{
            self.confirm(strMsg: msg, strOK: "Yes", strNG: "No", handler: {flg in
                if flg {
                    self.sendData()
                }else{
                    return
                }
            })
        }else{
        //失敗値が返却された場合, 不明なエラーの場合（リトライなし）
            self.alert(strMsg: msg, handler: {
                  return
            })
        }
        return
    }
}
