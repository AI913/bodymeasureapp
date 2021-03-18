//
//  VC_YesNoDIalog.swift
//  PITAMS
//
//  Created by admin on 2020/03/30.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit

protocol YesNoDelegate {
    func DialogEnd(result:Bool)
}

class VC_YesNoDIalog: UIViewController {
    @IBOutlet weak var lblMsg: UILabel!
    var delegate:YesNoDelegate!
    var msg:String = ""
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_YesNoDIalog", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *), CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        
        super.viewWillAppear(true)
        lblMsg.text = msg
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13.0, *), CV.FlgDemo == 2 {
            // iOS13以降の場合
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    
    @IBAction func tapNo(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate.DialogEnd(result: false)
        })
    }
    
    @IBAction func tapYes(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            self.delegate.DialogEnd(result: true)
        })
    }
}
