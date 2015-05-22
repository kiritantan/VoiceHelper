//
//  EditViewController.swift
//  speak
//
//  Created by kiri on 2015/05/09.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

class EditViewController: UIViewController,SSRadioButtonsDelegate {
    
    let ud = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet var japaneseButton: UIButton!
    @IBOutlet var englishButton: UIButton!
    @IBOutlet var selectRateSlider: UISlider!
    @IBOutlet var selectPitchSlider: UISlider!
    
    var radioButtonController = SSRadioButtonsController()
    var languageButtonArray:[UIButton]! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languageButtonArray = [japaneseButton,englishButton]
        radioButtonController.setButtonsArray(languageButtonArray)
        radioButtonController.delegate = self
        for  languageButton in languageButtonArray {
            if initSelectedButton(languageButton) {
                radioButtonController.pressed(languageButton)
            }
        }
        selectRateSlider.value = ud.floatForKey("rate")
        selectPitchSlider.value = ud.floatForKey("pitch")
    }
    
    func initSelectedButton(button:UIButton) -> Bool {
        if button.tag == ud.integerForKey("languageID") {
            return true
        } else {
            return false
        }
    }
    
    func didChangeSelectedButton(button: UIButton) {
        HilightSelectedLanguageButtonBackgroundColor(button)
    }
    
    func HilightSelectedLanguageButtonBackgroundColor(button:UIButton) {
        for languageButton in languageButtonArray {
            if button == languageButton {
                languageButton.backgroundColor = UIColor(red: 0.0, green: 0.478431, blue: 1, alpha: 1)
            } else {
                languageButton.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    
    
    @IBAction func didTapDecisionButton(sender: AnyObject) {
        saveParams()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveParams() {
        ud.setInteger(radioButtonController.selectedButton()?.tag ?? 10, forKey: "languageID")
        ud.setFloat(selectRateSlider.value, forKey: "rate")
        ud.setFloat(selectPitchSlider.value, forKey: "pitch")
        ud.synchronize()
    }
    
}
