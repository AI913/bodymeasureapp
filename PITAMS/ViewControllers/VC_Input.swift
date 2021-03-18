//
//  VC_Input.swift
//  PITAMS
//
//  Created by admin on 2020/03/31.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit

protocol InputDelegate {
    func inputEnd()
}

protocol httpEmpDelegate: class {
    func onSuccess(flg:Bool, data:EmpData?) -> Void
    func onFailed(msg: String, retryFlg:Bool) -> Void
}

class VC_Input: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate,PickerDelegate,YesNoDelegate, httpEmpDelegate {
    
    @IBOutlet weak var txtNumber: UITextField!
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var btnSize: UIButton!
    @IBOutlet weak var btnEmp:UIButton!
    @IBOutlet weak var txtHeight: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var imgMan: UIButton!
    @IBOutlet weak var imgWoman: UIButton!
    @IBOutlet weak var lblBMIVal: UILabel!
    @IBOutlet weak var viewBMIVal: UIView!
    @IBOutlet weak var imgSaveBtn: UIButton!
    @IBOutlet weak var imgTutorialBtn: UIButton!
    @IBOutlet weak var imgCancelBtn: UIButton!
    
    var delegate:InputDelegate!
    
    var flgBMIOver:Bool = false
    var flgSave:Bool = true
    var flgMan:Bool = true
    
    var selectSize:Int = 0
    
    let MaxN:Int = 10
    let MaxF:Int = 20
    let MaxL:Int = 20
    let MaxH:Int = 5
    let MaxW:Int = 3
    let MaxA:Int = 3
    
    //BMI関連
    let bmi_min:Double = RESDATA.loginRes?.bmi_min ?? 16.00
    let bmi_max:Double = RESDATA.loginRes?.bmi_max ?? 39.99
    
    let SizeLists:[String] = ["ゆったりめ", "ふつう", "きつめ"]
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Input", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }
    
    func initView(){
        CV.activityIndicatorView.center = view.center
        CV.activityIndicatorView.style = .whiteLarge
        CV.activityIndicatorView.color = .white
        
        view.addSubview(CV.activityIndicatorView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ジェスチャーの設定（キーボード解除のため）
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapView))
        tapGes.delegate = self
        
        self.view.addGestureRecognizer(tapGes)
        Util.eDelegate = self
        
        txtNumber.delegate = self
        txtFName.delegate = self
        txtLName.delegate = self
        txtHeight.delegate = self
        txtWeight.delegate = self
        txtAge.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *), CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }

        super.viewWillAppear(true)
        viewBMIVal.isHidden = true
        imgSaveBtn.imageView?.contentMode = .scaleAspectFit
        imgSaveBtn.contentHorizontalAlignment = .fill
        imgSaveBtn.contentVerticalAlignment = .fill
        imgTutorialBtn.imageView?.contentMode = .scaleAspectFit
        imgTutorialBtn.contentHorizontalAlignment = .fill
        imgTutorialBtn.contentVerticalAlignment = .fill
        imgCancelBtn.imageView?.contentMode = .scaleAspectFit
        imgCancelBtn.contentHorizontalAlignment = .fill
        imgCancelBtn.contentVerticalAlignment = .fill

        viewBMIVal.isHidden = false
        
        if CV.FlgDemo == 2{
            self.btnEmp.isEnabled = false
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //保存済みのデータがあれば表示
        onSuccess(flg: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13.0, *), CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //カメラに移動する場合
        if segue.identifier == "MoveToPicker" {
            let vc = segue.destination as! VC_Picker
            vc.delegate = self
            vc.dataList = SizeLists
        }
        else if segue.identifier == "MoveToDialog" {
            let vc = segue.destination as! VC_YesNoDIalog
            vc.delegate = self
            vc.msg = "社員情報を保存しますか？"
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let target = touch.view else {
            return false
        }
        CheckInputArea()
        //親Viewの場合にのみジェスチャーを機能させる
        if target == self.view {
            return true
        }
        else {
            return false
        }
    }
    
    //テキストフィールド終了時のイベント
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        CheckInputArea()
        switch textField.tag {
        case 0:
            // キーボードを閉じる
            textField.resignFirstResponder()
            //txtFName.becomeFirstResponder()
        case 1:
            txtFName.becomeFirstResponder()
        case 2:
            self.performSegue(withIdentifier: "MoveToPicker", sender: nil)
        case 3:
            txtWeight.becomeFirstResponder()
        case 4:
            txtAge.becomeFirstResponder()
        case 5:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    @objc func tapView(){
        self.view.endEditing(true)
    }
    
    @IBAction func tapBack(_ sender: Any) {
        viewBMIVal.isHidden = true
        self.backView()
    }
    
    @IBAction func tapConfig(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToConfig", sender: nil)
    }
    
    @IBAction func tapInput(_ sender: Any) {
        //インジケータを設定
        initView()
        //構造体 -> JSON
        var json:Data? = nil
        let encoder = JSONEncoder()
        let empinfo = EmpReq(employee_id: txtNumber.text ?? "")
        
        do {
            json = try encoder.encode(empinfo)
        }catch{
            //デコードエラー
            print("json decode error: VC_Input")
            self.alert(strMsg: MSG.ERR_FATAL, handler: {
                
            })
            return
        }
        
        if let json = json{
            //RESDATA.employee_id = self.txtNumber.text
            CV.activityIndicatorView.startAnimating()
            
            //POSTする
            if CV.FlgDemo == 2{
                Util.demoPostHttp(obj: self, method: #function)
            }else{
                
                if Util.connectionFlg {
                    //インターネット接続がある場合、POSTする
                    print("接続")
                    Util.PostHttp(obj: self, method: #function, stUrl: CV.empUrl, params: json, fn: { data in DispatchQueue.main.async {
                        }
                    })
                    
                } else {
                    print("接続がありません")
                    //接続がない場合、強制的に失敗させる
                    CV.activityIndicatorView.stopAnimating()
                    self.onFailed(msg: MSG.ALT_RTRY, retryFlg:true)
                }
            }
            
        }else{
            //json == nil の場合
            print("json is nil: VC_Input")
            self.alert(strMsg: MSG.ERR_FATAL, handler: {
                
            })
            return
        }
    }
    
    //社員データを保存済みの場合、もしくは社員情報の取得に成功した場合
    func onSuccess(flg:Bool = true, data: EmpData? = nil) {
        CV.activityIndicatorView.stopAnimating()
        
        if !flg{
            //保存済みデータを表示
            //社員番号
            self.txtNumber.text = RESDATA.employee_id ?? ""
            //名前
            self.txtFName.text = RESDATA.empRes?.first_name ?? ""
            //苗字
            self.txtLName.text = RESDATA.empRes?.last_name ?? ""
            //身長
            if let height = RESDATA.empRes?.height{
                self.txtHeight.text = NSString(format: "%.1f", Double(height)) as String
            }else {
                self.txtHeight.text = ""
            }
            //体重
            if let weight = RESDATA.empRes?.weight{
                self.txtWeight.text = String(weight)
            }else {
                self.txtWeight.text = ""
            }
            //年齢
            if let age = RESDATA.empRes?.age{
                self.txtAge.text = String(age)
            }else {
                self.txtAge.text = ""
            }
            //性別
            if let gender = RESDATA.empRes?.gender{
                switch gender{
                case 0:
                    self.tapMan(self.imgMan!)
                case 1:
                    self.tapWoman(self.imgWoman!)
                default:
                    self.tapMan(self.imgMan!)
                }
            }
            //サイズ感
            selectSize = (RESDATA.empRes?.size_feel ?? 2) - 1
            self.btnSize.setTitle(SizeLists[selectSize], for: .normal)
            //self.PickerEnd(result: (RESDATA.empRes?.size_feel ?? 2) - 1)
            
        }else{
            //レスポンスデータを表示
            //名前
            self.txtFName.text = data!.first_name
            //苗字
            self.txtLName.text = data!.last_name
            //身長
            if let height = data!.height{
                self.txtHeight.text = NSString(format: "%.1f", Double(height)) as String
            }else {
                self.txtHeight.text = ""
            }
            
            //サイズ感
            //self.PickerEnd(result: data?.size_feel ?? 2)
            
            //体重
            if let weight = data!.weight{
                self.txtWeight.text = String(weight)
            }else {
                self.txtWeight.text = ""
            }
            //年齢
            if let age = data!.age{
                self.txtAge.text = String(age)
            }else {
                self.txtAge.text = ""
            }
            
            //サイズ感
            selectSize = (data?.size_feel ?? 2) - 1
            self.btnSize.setTitle(SizeLists[selectSize], for: .normal)
            //self.PickerEnd(result: (data?.size_feel ?? 2) - 1)
            
            //性別
            if let gender = data!.gender{
                switch gender{
                case 0:
                    self.tapMan(self.imgMan!)
                case 1:
                    self.tapWoman(self.imgWoman!)
                default:
                    self.tapMan(self.imgMan!)
                }
            }
        }
        
        CalcBMI()
        CheckInputArea()
    }

    func onFailed(msg:String, retryFlg:Bool) {
        
        if retryFlg{
            //リトライする場合
            self.confirm(strMsg: msg, strOK: "Yes", strNG: "No", handler: {flg in
                if flg {
                    self.tapInput(self.btnEmp!)
                }else{
                    return
                }
            })
        }else{
            //ユーザーデータなし、不明なエラーの場合（リトライなし）
            self.alert(strMsg: msg, handler: {
                  return
            })
        }
        return
    }
    
    
    @IBAction func tapSize(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToPicker", sender: nil)
    }
    
    @IBAction func tapMan(_ sender: Any) {
        flgMan = true
        imgMan.setImage(UIImage(named: "man_active"), for: .normal)
        imgWoman.setImage(UIImage(named: "woman"), for: .normal)
    }
    
    @IBAction func tapWoman(_ sender: Any) {
        flgMan = false
        imgMan.setImage(UIImage(named: "man"), for: .normal)
        imgWoman.setImage(UIImage(named: "woman_active"), for: .normal)
    }
    
    @IBAction func tapCancel(_ sender: Any) {
        viewBMIVal.isHidden = true
        self.backView()
    }
    
    //保存
    @IBAction func tapSave(_ sender: Any) {
        if flgSave{
            //nil, 入力値チェック
            guard CheckVal() == true else {
                print("failed val check")
                return
            }

            CheckInputArea()

            if !flgBMIOver{
                self.alert(strMsg: MSG.OVER_BMI, handler: {
                    return
                })
            }

            self.confirm(strMsg: MSG.SAVE_CNF, strOK: "Yes", strNG: "No", handler: {flg in
                if flg{
                    self.saveData()
                    self.backView()
                }else{
                    return
                }
            })
        }
    }
    
    func saveData(){
        //共有データに一時保存
        let data = EmpData(
                res: 0,
                last_name: self.txtLName.text!,
                first_name: self.txtFName.text!,
                size_feel: self.selectSize + 1,
                height: Int(NSString(string: self.txtHeight.text!).doubleValue),
                weight: NSString(string: self.txtWeight.text!).integerValue as Int,
                age: NSString(string: self.txtAge.text!).integerValue as Int,
                gender: flgMan ? 0:1)
        
        RESDATA.employee_id = self.txtNumber.text
        RESDATA.empRes = data
        //print("data", data)
        
        viewBMIVal.isHidden = true
    }
    
//    func saveMeasurements(){
//        armLength =
//    }
    
    @IBAction func tapTutorial(_ sender: Any) {
        self.performSegue(withIdentifier: "MoveToTutrial", sender: nil)
    }
    
    //入力チェック
    func CheckInputArea(){
        //社員番号入力
        if txtNumber.text!.count > MaxN{
            //字数オーバーの場合
            self.alert(strMsg: MSG.ALT_OVER_EMPVAL, handler: {
                self.txtNumber.becomeFirstResponder()
            })
            return
        }
        
        //英数字以外を入力した場合
        if !txtNumber.text!.isOnlyAlphabetNumeric(){
            self.alert(strMsg: MSG.ALT_OVER_EMPVAL, handler: {
                self.txtNumber.becomeFirstResponder()
            })
        }
        
        //名前（姓）
        if txtFName.text!.count > MaxF{
            //エラー
            self.alert(strMsg: MSG.ALT_OVER_LNAME, handler: {
                self.txtFName.becomeFirstResponder()
            })
            return
        }
        
        //名前（名）
        if txtLName.text!.count > MaxL{
            //エラー
            self.alert(strMsg: MSG.ALT_OVER_FNAME, handler: {
                self.txtLName.becomeFirstResponder()
            })
            return
        }
        
        //身長（数値チェック）
        if !txtHeight.text!.isEmpty{
            
            if !txtHeight.text!.isOnlyNumericDot(){
                //エラー
                self.alert(strMsg: MSG.ALT_HEIGHT, handler: {
                    self.txtHeight.becomeFirstResponder()
                })
                return
            }
        }
        
        //身長（桁数チェック）
        if !txtHeight.text!.isEmpty{
            
            if txtHeight.text!.count > MaxH{
        
                for (idx, c) in txtHeight.text!.enumerated(){
                    if idx == 4 && c == "."{
                        self.alert(strMsg: MSG.ALT_HEIGHT, handler: {
                            self.txtHeight.becomeFirstResponder()
                        })
                        return
                    }
                }
            }
        }
        
        //体重（数値チェック）
        if !txtWeight.text!.isEmpty{
                    
            if !txtWeight.text!.isOnlyNumeric(){
                //エラー
                self.alert(strMsg: MSG.ALT_WEIGHT, handler: {
                    self.txtWeight.becomeFirstResponder()
                })
                return
            }
        }
        
        //体重（桁数チェック）
        if !txtWeight.text!.isEmpty{
            
            if txtWeight.text!.count > MaxW{
                //エラー
                self.alert(strMsg: MSG.ALT_WEIGHT, handler: {
                    self.txtWeight.becomeFirstResponder()
                })
                return
            }
        }
        
        //年齢（数値チェック）
        if !txtAge.text!.isEmpty{
            
            if !txtAge.text!.isOnlyNumeric(){
                //エラー
                self.alert(strMsg: MSG.ALT_AGE, handler: {
                    self.txtAge.becomeFirstResponder()
                })
                return
            }
        }
        
        //年齢（桁数チェック）
        if !txtAge.text!.isEmpty{
            if txtAge.text!.count > MaxA{
                //エラー
                self.alert(strMsg: MSG.ALT_AGE, handler: {
                    self.txtAge.becomeFirstResponder()
                })
                return
            }
        }
        
        CalcBMI()
        
//        if CheckVal(){
            flgSave = true
            imgSaveBtn.setImage(UIImage(named: "footer_save_active-1"), for: .normal)
//        }
//        else{
//            flgSave = false
//            imgSaveBtn.setImage(UIImage(named: "footer_save-1"), for: .normal)
//        }
        
        //BMI許容値オーバーの場合、インジケーターを赤にする
        if !flgBMIOver{
            //self.lblBMIVal.textColor = UIColor.magenta
            self.viewBMIVal.backgroundColor = UIColor.magenta
        }
        
        //CalcBMI()
    }
    
    //入力済みかチェック
    func CheckVal()->Bool{
        if txtNumber.text! == "" || txtFName.text! == "" || txtLName.text! == "" || txtHeight.text! == "" || txtWeight.text! == "" || txtAge.text! == ""{
            self.alert(strMsg: MSG.ALT_HAS_NODATA, handler: {})
            return false
        }
        return true
    }
    
    //BMIの計算
    func CalcBMI(){
        var Angle:CGFloat = 0
        
        if txtWeight.text == nil || txtWeight.text == "" || txtHeight.text == nil || txtHeight.text == ""{
            Angle = 0
            lblBMIVal.text = "-"
        }
        else{
            let hs:String = txtHeight.text!
            let ws:String = txtWeight.text!
            
            let h:Double = (Double(hs)! / 100)
            let w:Double = Double(ws)!
            var bmi:Double = round(w / (h * h) * 100) / 100
            
            lblBMIVal.text = String(bmi)
            if bmi_min > bmi{
                bmi = bmi_min
                flgBMIOver = false
            }
            else if bmi > bmi_max{
                bmi = bmi_max
                flgBMIOver = false
            }
            else{
                self.viewBMIVal.backgroundColor = CV.COLOR_SELECT
                //self.lblBMIVal.textColor = UIColor.white
                flgBMIOver = true
            }
            
            let val = round((bmi - bmi_min) / (bmi_max - bmi_min) * 100) / 100
            Angle = CGFloat(round(180 * val))
        }

        UIView.animate(withDuration: 0.5, animations: {
            self.viewBMIVal.transform = CGAffineTransform(rotationAngle: Angle * CGFloat.pi / 180)
        })
    }
    
    //ピッカーの終わり
    func PickerEnd(result: Int) {
        selectSize = result
        btnSize.setTitle(SizeLists[selectSize], for: .normal)
        txtHeight.becomeFirstResponder()
        return
    }
    //ダイアログの返り値
    func DialogEnd(result: Bool) {
        if result{
            //共通クラスに一時保存
            let data = EmpData(
                    res: 0,
                    last_name: self.txtLName.text!,
                    first_name: self.txtFName.text!,
                    height: Int(NSString(string: self.txtHeight.text!).doubleValue * 10.0),
                    weight: NSString(string: self.txtWeight.text!).integerValue as Int,
                    age: NSString(string: self.txtAge.text!).integerValue as Int,
                    gender: flgMan ? 0:1)
            
            RESDATA.employee_id = self.txtNumber.text
            RESDATA.empRes = data
            
            viewBMIVal.isHidden = true
            self.delegate.inputEnd()
            self.backView()
        }else{
            self.backView()
        }
    }
}
