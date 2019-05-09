//
//  SearchWordViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/08.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class SearchWordViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnToDictionaryViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnToDictionaryViewController") {
            let _: DictionaryViewController = (segue.destination as? DictionaryViewController)!
        }
    }
}
