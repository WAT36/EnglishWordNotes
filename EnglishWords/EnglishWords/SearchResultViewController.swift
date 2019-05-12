//
//  SearchResultViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/12.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class SearchResultViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnSearchWordViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnSearchWordViewController") {
            let _: SearchWordViewController = (segue.destination as? SearchWordViewController)!
        }
    }
}
