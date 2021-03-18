//
//  VC_Tutorial.swift
//  PITAMS
//
//  Created by admin on 2020/03/31.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit

class VC_Tutorial: UIViewController {
    //チュートリアルのカウンター
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var navi1: UIImageView!
    @IBOutlet weak var navi2: UIImageView!
    @IBOutlet weak var navi3: UIImageView!
    @IBOutlet weak var navi4: UIImageView!
    @IBOutlet weak var navi5: UIImageView!
    @IBOutlet weak var navi6: UIImageView!
    @IBOutlet weak var navi7: UIImageView!
    @IBOutlet weak var navi8: UIImageView!
    @IBOutlet weak var ViewPicutures: UIView!
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var imgSlideL: UIButton!
    @IBOutlet weak var imgSlideR: UIButton!
    
    var naviList:[UIImageView] =  []
    var SelectPic:Int = 0
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Tutorial", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naviList = [navi1, navi2, navi3, navi4, navi5, navi6, navi7, navi8]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13.0, *),CV.FlgDemo == 2{
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    //キャンセルボタン
    @IBAction func tapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //左スライド
    @IBAction func tapLSlider(_ sender: Any) {
        MoveImages(flg:true)
    }
    //右スライド
    @IBAction func tapRSlider(_ sender: Any) {
        MoveImages(flg:false)
    }
    //右スワイプ
    @IBAction func SwipeR(_ sender: Any) {
        MoveImages(flg:true)
    }
    //左スワイプ
    @IBAction func SwipeL(_ sender: Any) {
        MoveImages(flg:false)
    }
    
    //画像の移動
    func MoveImages(flg:Bool){
        //左へ
        if flg{
            if SelectPic == (CV.FIRST_PAGE) {
                return
            }
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseIn], animations: {
                self.ViewPicutures.center.x += (self.img.frame.width + 8)
            }, completion: nil)
            SelectPic-=1
        }
        //右へ
        else{
            if SelectPic == CV.LAST_PAGE {
                return
            }
            UIView.animate(withDuration: 0.15, delay: 0.0, options:[.curveEaseIn], animations: {
                self.ViewPicutures.center.x -= (self.img.frame.width + 8)
            }, completion: nil)
            SelectPic+=1
        }
        ChangeNavi(val: SelectPic)
    }
    //ナビの移動
    func ChangeNavi(val:Int){
        for i in 0...CV.LAST_PAGE{
            if (i == val){
                naviList[i].image = UIImage(named:"slider_mark_active")
            }else{
                naviList[i].image = UIImage(named:"slider_mark")
            }
        }
        lblCounter.text = "(" + String(SelectPic + 1) + "/" + String(CV.LAST_PAGE + 1) + ")"
        if SelectPic == (CV.FIRST_PAGE) {
            imgSlideL.setImage(UIImage(named: "slider_arrow_L"), for: .normal)
            imgSlideR.setImage(UIImage(named: "slider_arrow_R_active"), for: .normal)
            return
        }
        else if SelectPic == CV.LAST_PAGE {
            imgSlideL.setImage(UIImage(named: "slider_arrow_L_active"), for: .normal)
            imgSlideR.setImage(UIImage(named: "slider_arrow_R"), for: .normal)
            return
        }
        imgSlideL.setImage(UIImage(named: "slider_arrow_L_active"), for: .normal)
        imgSlideR.setImage(UIImage(named: "slider_arrow_R_active"), for: .normal)
    }
}
