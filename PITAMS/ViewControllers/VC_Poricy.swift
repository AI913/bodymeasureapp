//
//  VC_Poricy.swift
//  PITAMS
//
//  Created by admin on 2020/04/10.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit
import WebKit

class VC_Poricy: UIViewController {
    @IBOutlet weak var wv: WKWebView!
    
    //本番リリース時はhttpsにする
    let urlStr:String = CV.poricyUrl
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Poricy", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: urlStr)
        let myRequest = URLRequest(url: myURL!)
        wv.load(myRequest)
    }

    @IBAction func tapBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
