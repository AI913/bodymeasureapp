//
//  VC_Login.swift
//  PITAMS
//  Created by admin on 2020/03/31.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit
import SwiftUI

@main
struct SwiftCPPApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

protocol httpLoginDelegate : class{
    func onSuccess() -> Void
    func onFailed(msg:String, retryFlg:Bool) -> Void
}

struct ContentView: View {
    var body: some View {
        Text(PITAMSWrapper().sayHello()).padding()
    }
}

class VC_Login: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, httpLoginDelegate {
    @IBOutlet weak var txtCompany: UITextField! //userid
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    var flgPP:Bool = false
    var flgLogin:Bool = false
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Login", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as? UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCompany.delegate = self
        txtPass.delegate = self
        Util.lDelegate = self
        txtCompany.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        //ジェスチャーの設定（キーボード解除のため）
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapView))
        tapGes.delegate = self
        
        self.view.addGestureRecognizer(tapGes)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) , CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //テキストフィールド終了時のイベント
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkInput()
        if textField.tag == 0{
            txtPass.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let target = touch.view else {
            return false
        }
        checkInput()
        return true
    }
    @objc func tapView(){
        self.view.endEditing(true)
    }
    
    //プライバシーポリシーのチェック
    @IBAction func tapCheck(_ sender: Any) {
        flgPP = !flgPP
        if flgPP{
            btnCheck.setImage(UIImage(named: "privacy_check_active"), for: .normal)
        }else{
            btnCheck.setImage(UIImage(named: "privacy_check"), for: .normal)
        }
        checkInput()
    }
    
    @IBAction func tapLogin(_ sender: Any) {
//        self.performSegue(withIdentifier: "MoveToTop", sender: nil)
//        //インジケータを設定
//        CV.activityIndicatorView.center = view.center
//        CV.activityIndicatorView.style = .whiteLarge
//        CV.activityIndicatorView.color = .white
//        view.addSubview(CV.activityIndicatorView)
//
//        if flgLogin{
//            //POSTの準備
//            var json:Data? = nil
//            let encoder = JSONEncoder()
//            let empinfo = LoginReq(company_id: self.txtCompany.text!, password: self.txtPass.text!)
//            //POST前にログイン情報を保持
//            RESDATA.lodinReq = empinfo
//            do {
//                json = try encoder.encode(empinfo)
//            }catch{
//                //デコードエラー
//                print("json decode error: VC_Input")
//                self.alert(strMsg: MSG.ERR_FATAL, handler: {
//                    self.backView()
//                })
//                return
//            }
//
//            if let json = json{
//                CV.activityIndicatorView.startAnimating()
//                //POSTする
//                if CV.FlgDemo == 2{
//                    Util.demoPostHttp(obj: self, method: #function)
//                }else{
//
//                    if Util.connectionFlg {
//                        //インターネット接続がある場合、POSTする
//                        print("接続")
//                        Util.PostHttp(obj: self, method: #function, stUrl: CV.loginUrl, params: json, fn: { data in DispatchQueue.main.async {
//                            }
//                        })
//                    } else {
//                        print("接続がありません")
//                        //接続がない場合、強制的に失敗させる
//                        DispatchQueue.main.async {
//                            CV.activityIndicatorView.stopAnimating()
//                        }
//                        self.onFailed(msg: MSG.ALT_RTRY, retryFlg:true)
//                    }
//                }
//            }
//        }
        onSuccess()
    }
    
    func onSuccess() {
        // success, 画面遷移など
        
        DispatchQueue.main.async {
            CV.activityIndicatorView.stopAnimating()
            print("move to top")
            self.performSegue(withIdentifier: "MoveToTop", sender: nil)
        }
    }
    
    func onFailed(msg:String, retryFlg:Bool) {
        if retryFlg{
        //リトライする場合
            self.confirm(strMsg: msg, strOK: "Yes", strNG: "No", handler: {flg in
                if flg {
                    self.tapLogin(self.btnLogin!)
                }else{
                    self.backView()
                }
            })
        }else{
        //ユーザーデータがない場合, 不明なエラーの場合（リトライなし）
            self.alert(strMsg: msg, handler: {
                self.backView()
            })
        }
        return
    }
    
    @IBAction func tapPP(_ sender: Any) {
        //プライバシーポリシーのPDFファイルなどをサーバにおいて公開してもらう様にお願いする
        self.performSegue(withIdentifier: "MoveToPoricy", sender: nil)
    }
    
    func checkInput(){
        //入力チェック（ログイン認証なので桁数チェックとかはいらないはず）
        if txtCompany.text!.count > 0  && !txtCompany.text!.isOnlyNumeric() {
            self.alert(strMsg: MSG.ALT_ERR_ID, handler: {
                self.txtCompany.becomeFirstResponder()
                return
            })
        }
        
        if txtCompany.text!.count > 0 && txtPass.text!.count > 0 && flgPP {
            flgLogin = true
            btnLogin.setImage(UIImage(named: "btn_login_active"), for: .normal)
        }
        else{
            flgLogin = false
            btnLogin.setImage(UIImage(named: "btn_login"), for: .normal)
        }
    }
}
