//
//  OptionConfigureWordNoteViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/07/01.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class OptionConfigureWordNoteViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet var viewName: UILabel!
    @IBOutlet var wordOrderby: UIPickerView!
    @IBOutlet var wordNameSegmentedControl: UISegmentedControl!

    let singleton :Singleton = Singleton.sharedInstance

    let sortByList = Singleton.sharedInstance.getMenu(key: "Menu.optionConfigureWordNote.sortName")
    let sortAttributeByList = Singleton.sharedInstance.getMenu(key: "Menu.optionConfigureWordNote.sortAttribute")
    var selectedSortBy = Singleton.sharedInstance.getStringValue(key: "Menu.optionConfigureWordNote.sortDefaultAttribute") //デフォルトの並び順

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面名ラベル設定、２行
        viewName.text = "単語帳設定\nオプション"
        viewName.numberOfLines = 2
        
        // ボタンを選択中にする場所を指定
        wordNameSegmentedControl.selectedSegmentIndex = 1
        // ボタン選択時にボタンを選択状態にするかどうかの設定
        wordNameSegmentedControl.isMomentary = false
        
        // 現並び順の設定
        selectedSortBy = singleton.getWordNoteSortBy()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //キーボード外タップしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortByList.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return sortByList[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        selectedSortBy = sortAttributeByList[row]
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 1){
            singleton.saveWordNoteSortBy(wnsb: selectedSortBy)
            singleton.saveWordNoteSortAscend(wnsa: (wordNameSegmentedControl.selectedSegmentIndex == 0))
        }
        performSegue(withIdentifier: singleton.getStringValue(key: "Segue.optionConfigureWordNote.configureWordNoteBook"),sender: nil)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == singleton.getStringValue(key: "Segue.optionConfigureWordNote.configureWordNoteBook") ) {
            let _: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
        }
    }
}
