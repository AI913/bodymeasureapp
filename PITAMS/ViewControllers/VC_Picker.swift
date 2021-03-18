//
//  VC_Picker.swift
//  PITAMS
//
//  Created by admin on 2020/04/07.
//  Copyright © 2020 frontarc. All rights reserved.
//

import UIKit

protocol PickerDelegate {
    func PickerEnd(result:Int)
}

class VC_Picker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var pckr: UIPickerView!
    
    var dataList:[String] = []
    var delegate:PickerDelegate!
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: "VC_Picker", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as! UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pckr.backgroundColor = .darkGray
    }

    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
     func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        // 表示するラベルを生成する
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        label.textAlignment = .center
        label.text = dataList[row]
        label.font = UIFont(name:"YuGothic" , size: 30)
        label.textColor = .white
        label.backgroundColor = .darkGray
        return label
     }
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return dataList[row]
    }
     
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        self.dismiss(animated: true, completion: {
            self.delegate.PickerEnd(result: row)
        })
    }
}
