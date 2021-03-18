//
//  ConstValue.swift
//  PITAMS
//
//  Created by admin on 2019/10/11.
//  Copyright © 2019 frontarc. All rights reserved.
//

import Foundation
import UIKit

struct CV {
    
    //オフラインデモモードのフラグ
    //0=本番URL, 1=テストURL, 2=オフラインデモモード
    public static var FlgDemo:Int = 1
    
    //URL
    public static var loginUrl:String = ""
    public static var empUrl:String = ""
    public static var uploadUrl:String = ""
    public static var poricyUrl:String = ""

    public static func initUrl() {
        switch CV.FlgDemo{
        case 0:
            //本番環境
            CV.loginUrl = "http://18.182.182.6/api/login"
            CV.empUrl = "http://18.182.182.6/api/empinfo"
            CV.uploadUrl = "http://18.182.182.6/api/upload"
            CV.poricyUrl = "http://18.182.182.6/static/privacy-policy.html"
        case 1:
            //テストURL
            print("switch to Test Mode")
            CV.loginUrl = "http://192.168.11.107:5000/login"
            CV.empUrl = "http://192.168.11.107:5000/empinfo"
            CV.uploadUrl = "http://192.168.11.107:5000/upload"
            CV.poricyUrl = "http://18.182.182.6/static/privacy-policy.html"
        case 2:
            print("switch to Offline Demo Mode")
        default:
            print("Index Error: Flg value out of range")
        }
    }
    
    //リクエストのタイムアウト
    public static var timeout:Int = 20
    //インジケータ
    public static var activityIndicatorView = UIActivityIndicatorView()
    //画像表示領域・撮影タイプ識別
    public static let PTN_WIDE:Int = 0
    public static let PTN_SIDE:Int = 1
    public static let PTN_ALL:Int = -1
    //画像識別
    public static let TYPE_NORMAL:Int = 0
    //チュートリアルのページ数
    public static let FIRST_PAGE:Int = 0
    public static let LAST_PAGE:Int = 7
    //ジャイロセンサー関連
    public static let MTN_INTERVAL:Double   = 0.1
    public static let MTN_ROUND:Double      = 100
    public static let mCoefficient:CGFloat = 5
    public static var MMFlg:Bool = true
    public static var magniZ:Float = 0.1
    public static var magniX:Float = 0.1
    public static var GyroFlg:Bool = false
    //基準サイズ
    public static let PIC_X:Float = 1440
    public static let PIC_Y:Float = 2560
    //確定サイズ
    public static var imgSizeX:Int = 720
    public static var imgSizeY:Int = 1280
    //サイズ保存用
    public static var picsizeSldrVal:Float = 0.5
    //ライン関連
    public static let LINE_W:Int = 0
    public static let LINE_H:Int = 1
    public static let LINE_L:Int = 2
    //ライン表示フラグ
    public static var LineFlg:Bool = true
    
    //閾値値
    public static var threshold:Int = 125
    //二値化オン/オフ
    public static var THFlg:Bool = true
    
    //色関連
    public static let COLOR_SELECT:UIColor = UIColor(displayP3Red: 0, green: 210, blue: 255, alpha: 255)
    public static let COLOR_WAIT:UIColor = .white
}

struct RESDATA{
    // レスポンスデータ格納場所
    public static var employee_id:String?
    public static var loginRes:LoginData?
    public static var empRes:EmpData?
    public static var uploadRes:UploadData?
}

// ログインレスポンス
struct LoginData: Codable {
    var res: Int
    var company_name: String
    var bmi_min: Double
    var bmi_max: Double
}

//ログインリクエスト
struct LoginReq: Codable {
    var company_id: String
    var password: String
}

//社員情報レスポンス
struct EmpData: Codable {
    var res: Int
    var last_name: String
    var first_name: String
    var size_feel: Int?
    var height: Int?
    var weight: Int?
    var age: Int?
    var gender: Int?
}

//社員情報リクエスト
struct EmpReq:Codable{
    var employee_id:String
}

//画像アップロードのレスポンス
struct UploadData: Codable {
    var res: Int
}

//画像アップロードのリクエスト
struct UploadReq: Codable{
    var employee_id:String
    var images:[String]
    var last_name: String
    var first_name: String
    var size_feel: Int
    var height: Int
    var weight: Int
    var age: Int
    var gender: Int
    //オプショナルなライン
    var waist:Int?
    var hip:Int?
    var hem:Int?
    
}

struct ErrorCheck: Codable {
    var res: Int
}

struct Message: Codable {
    var message: String
}


//メッセージは日本語英語で切り替えが必要？
struct MSG {
    //ログイン画面: 通信エラーメッセージ
    public static let ALT_RTRY:String = "ネットワークエラーが発生しました。もう一度やり直しますか？"
    public static let ALT_NO_USER:String = "ユーザ名、またはパスワードが間違っています。"
    public static let ALT_ERR_ID: String = "Company IDは半角数字のみで入力してください。"
    //メイン画面:入力チェックメッセージ
    public static let ALT_OVER_EMPVAL: String = "社員番号は10桁以内の英数で入力してください。"
    public static let ALT_OVER_LNAME:String = "苗字は20桁以内で入力してください。"
    public static let ALT_OVER_FNAME:String = "名前は20桁以内で入力してください。"
    public static let ALT_WEIGHT:String = "体重は３桁以内の数値で入力してください。"
    public static let ALT_AGE:String = "年齢は３桁以内の数値で入力してください。"
    public static let ALT_HEIGHT:String = "身長は数値且つ、小数点第一位以内で入力してください。"
    public static let ALT_HAS_NODATA:String = "未入力項目があります。"
    public static let OVER_BMI:String = "BMI値が異常です。身長と体重を正しく入力してください。"
    public static let ALT_NO_EMP:String = "入力された社員番号は存在しません。"
    public static let SAVE_CNF:String = "社員情報を保存しますか？"
    //カメラ画面:エラーメッセージ
    public static let ERR_CMR_RST:String = "顔を認識できませんでした。撮り直してください。"
    public static let ERR_CMR_MISS:String = "撮影に失敗しました。撮り直してください。"
    public static let ERR_CMR_SNR:String = "ご利用の端末のカメラは本アプリに対応しておりません。"
    public static let ERR_CMR_MTN:String = "ジャイロセンサーが利用できません。"
    public static let ERR_CMR_RTC:String = "iPhoneが傾きすぎです。正しく構えてください。"
    //共通エラーメッセージ
    public static let ERR_FATAL:String = "予期せぬエラーが発生しました。"
    //アップロード画面:完了メッセージ
    public static let PRG_COMPLATE:String = "データの送信が完了しました。"
    public static let PRG_FAILED:String = "データの送信に失敗しました。"
    
    //デモ画面:エラーメッセージ
    public static let ERR_DM:String = "フォトライブラリの取得に失敗しました。"
}

class Util{
    
    public static let PIC_DEF:Int = 0
    public static let PIC_FRM:Int = 1
    public static let PIC_TGT:Int = 2
    public static let PIC_DMY:Int = 3
    public static let PIC_GYR:Int = 4
    
    static var PicTemplate:[[UIImage?]] = []
    public static func PicInit()->[[UIImage?]]{
        PicTemplate = [
        [UIImage(named: "photo_wide")!, UIImage(named: "camera_wide")!, nil, nil, UIImage(named: "camera_wide_shadow")!] ,
        [UIImage(named: "photo_side")!, UIImage(named: "camera_side")!,nil, nil, UIImage(named: "camera_side_shadow")!]
        ]
        
        return PicTemplate
    }
    
    // イベントを通知する先
    static weak var lDelegate: httpLoginDelegate?
    static weak var eDelegate: httpEmpDelegate?
    static weak var uDelegate: httpUploadDelegate?
    
    // JSONデコーダー
    static let decoder: JSONDecoder = JSONDecoder()
    
    //現在日の取得
    public static func GetNowDate()->String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }
    
    // POST
    public static func PostHttp(obj:UIViewController, method: String, stUrl:String, params:Data, fn:@escaping (_ data: String)->Void){
        let u = URL(string: stUrl)
        // URLRequestオブジェクトにタイムアウト設定
        var r = URLRequest(url:u!, timeoutInterval: TimeInterval(CV.timeout))
        r.httpMethod = "POST" // POSTを指定
        r.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            r.httpBody = params
            print("httpBody", r.httpBody)

            let task:URLSessionDataTask = URLSession.shared.dataTask(with: r as URLRequest, completionHandler: {(data,response,error) -> Void in

                // 接続エラーの場合
                if error != nil {
                    DispatchQueue.main.async {
                        print("connection failed...")

                        // インジケータをストップ
                        CV.activityIndicatorView.stopAnimating()

                        // delegateで通知する場合
                        showDialog(method: method, rFlg: true, fError: false)
                        return
                    }
                }

                if let data = data{
                    DispatchQueue.main.async {
                        print("connection success!")
                        
                        // インジケータをストップ
                        CV.activityIndicatorView.stopAnimating()
                        
                        if resCodeisSuccess(rowData: data){
                            // サーバから成功値が返っている場合
                            let resultData = String(data: data, encoding: .utf8)!
                            print("result:\(resultData)")
                            
                            // JSONをデコード
                            self.jsonDecode(method: method, rowData:data)


                        }else{
                            // 失敗値が返っている場合 -> デバッグ時コメントアウト外してください
                            /*
                            do {
                                let data: Message = try decoder.decode(Message.self, from: data)
                                
                                print("error: ", data.message)
                                
                            } catch let e {
                                showDialog(method: method, msg: MSG.ERR_FATAL, rFlg: false)
                                print("JSON Decode Error :\(e)")
                            }
                            */
                            print("return failed value")
                            showDialog(method: method,rFlg: false, fError: false)
                            
                        }
                    }
                }else{
                    jsonDecode(method: method, rowData: Data())
                    print("return data is empty!")
                    return
                }
            })
            task.resume()
            
        }catch{
            // インジケータをストップ
            CV.activityIndicatorView.stopAnimating()
            print("JSON serialize error!")
            showDialog(method: method, rFlg: false, fError: true)
        }
    }
    
    //オフラインデモモード用の空POST関数
    public static func demoPostHttp(obj:UIViewController, method: String){
        switch method {
        // 画像アップロード時
        case "sendData()":
                let data = UploadData(res: 0)
                RESDATA.uploadRes = data
                Util.uDelegate?.onSuccess()
                print("upload - data parsed")
        default:
            print(method, ": no such method")
        }
        
        
    }
    
    
    // サーバからの返却値チェック関数
    static func resCodeisSuccess(rowData:Data)->Bool{
        do {
            let data: ErrorCheck = try decoder.decode(ErrorCheck.self, from: rowData)
            if data.res == 0{
                return true
            }else {
                return false
            }
        } catch let e {
            print("JSON Decode Error :\(e)")
            return false
        }
    }
    
    // レスポンスされたJSONをデコードする関数
    static func jsonDecode(method: String, rowData:Data){
        switch method {
        // ログイン時
        case "tapLogin(_:)":
            do {
                let data: LoginData = try decoder.decode(LoginData.self, from: rowData)
                RESDATA.loginRes = data
                print("data: ", data)
                print("common:loginRes: ", RESDATA.loginRes)
                print("login - data parsed")
                self.lDelegate?.onSuccess()
            } catch let e {
                print("JSON Decode Error :\(e)")
                showDialog(method: method, rFlg: false, fError: true)
            }
        //社員データ取得時
        case "tapInput(_:)":
            do {
                let data: EmpData = try decoder.decode(EmpData.self, from: rowData)
                //RESDATA.empRes = data
                self.eDelegate?.onSuccess(flg: true, data: data)
                print("emp - data parsed")
            } catch let e {
                print("JSON Decode Error :\(e)")
                showDialog(method: method, rFlg: true, fError: true)
            }
        // 画像アップロード時
        case "sendData()":
            do {
                let data: UploadData = try decoder.decode(UploadData.self, from: rowData)
                RESDATA.uploadRes = data
                self.uDelegate?.onSuccess()
                print("upload - data parsed")
            } catch let e {
                print("JSON Decode Error :\(e)")
                self.uDelegate?.onFailed(msg: MSG.ERR_FATAL, retryFlg:false)
            }
        default:
            print(method, ": no such method")
        }
    }
    
    // リトライチェック
    static func showDialog(method: String, rFlg: Bool, fError: Bool){ //fatal以外はmsg受け取れない場合あり
        switch method {
        // ログイン時
        case "tapLogin(_:)":
            if rFlg{
                self.lDelegate?.onFailed(msg: MSG.ALT_RTRY, retryFlg:true) //通信エラー
            }else if fError{
                self.lDelegate?.onFailed(msg: MSG.ERR_FATAL, retryFlg:false) //致命的エラー
            }else{
                self.lDelegate?.onFailed(msg: MSG.ALT_NO_USER, retryFlg:false) //ユーザーデータなし
            }
        //社員データ取得時
        case "tapInput(_:)":
            if rFlg{
                self.eDelegate?.onFailed(msg: MSG.ALT_RTRY, retryFlg:true) //通信エラー
            }else if fError{
                self.eDelegate?.onFailed(msg: MSG.ERR_FATAL, retryFlg:false) //致命的エラー
            }else{
                self.eDelegate?.onFailed(msg: MSG.ALT_NO_EMP, retryFlg:false) //社員データなし
            }
        // 画像アップロード時
        case "sendData()":
            if rFlg{
                self.uDelegate?.onFailed(msg: MSG.ALT_RTRY, retryFlg:true) //通信エラー
            }else if fError{
                self.uDelegate?.onFailed(msg: MSG.ERR_FATAL, retryFlg:false) //致命的エラー
            }else{
                self.uDelegate?.onFailed(msg: MSG.PRG_FAILED, retryFlg:false) //失敗値が返却された場合
            }
        default:
            print(method, ": no such method")
        }
    }
}
