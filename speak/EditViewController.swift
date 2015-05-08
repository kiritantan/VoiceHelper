//
//  EditViewController.swift
//  speak
//
//  Created by kiri on 2015/05/09.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

class EditViewController: UIViewController{
    
    let ud = NSUserDefaults.standardUserDefaults()
    @IBOutlet var selectLanguageSegmentedControl: UISegmentedControl!
    @IBOutlet var selectRateSlider: UISlider!
    @IBOutlet var selectPitchSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectLanguageSegmentedControl.selectedSegmentIndex = ud.integerForKey("languageID")
        selectRateSlider.value = ud.floatForKey("rate")
        selectPitchSlider.value = ud.floatForKey("pitch")
    }
    
    @IBAction func didTapDecisionButton(sender: AnyObject) {
        ud.setInteger(selectLanguageSegmentedControl.selectedSegmentIndex, forKey: "languageID")
        ud.setFloat(selectRateSlider.value, forKey: "rate")
        ud.setFloat(selectPitchSlider.value, forKey: "pitch")
        ud.synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
