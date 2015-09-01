//
//  EditViewController.swift
//  speak
//
//  Created by kiri on 2015/05/09.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import MediaPlayer

class EditViewController: UIViewController,SSRadioButtonsDelegate {
    
    let ud = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet var mpVolumeParentView: UIView!
    @IBOutlet var japaneseButton: UIButton!
    @IBOutlet var englishButton: UIButton!
    @IBOutlet var placeLeftPlayButton: UIButton!
    @IBOutlet var placeRightPlayButton: UIButton!
    @IBOutlet var selectRateSlider: UISlider!
    @IBOutlet var selectPitchSlider: UISlider!
    
    var langageRadioButtonController = SSRadioButtonsController()
    var placeRadioButtonController = SSRadioButtonsController()
    var languageButtonArray:[UIButton]! = nil
    var placeButtonArray:[UIButton]!    = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languageButtonArray = [japaneseButton,englishButton]
        placeButtonArray    = [placeLeftPlayButton,placeRightPlayButton]
        langageRadioButtonController.setButtonsArray(languageButtonArray)
        placeRadioButtonController.setButtonsArray(placeButtonArray)
        langageRadioButtonController.delegate = self
        placeRadioButtonController.delegate   = self
        for languageButton in languageButtonArray {
            if isSelectedButton(languageButton) {
                langageRadioButtonController.pressed(languageButton)
            }
        }
        for placeButton in placeButtonArray {
            if isSelectedButton(placeButton) {
                placeRadioButtonController.pressed(placeButton)
            }
        }
        selectRateSlider.value = ud.floatForKey("rate")
        selectPitchSlider.value = ud.floatForKey("pitch")
        let deviceOrientation: UIInterfaceOrientation!  = UIApplication.sharedApplication().statusBarOrientation
        if deviceOrientation.isLandscape {
            if Int( UIScreen.mainScreen().bounds.size.width) <= 736 {
                selectRateSlider.hidden = true
                selectPitchSlider.hidden = true
            }
        } else {
            selectRateSlider.hidden = false
            selectPitchSlider.hidden = false
        }
        let myVolumeView = MPVolumeView(frame: mpVolumeParentView.bounds)
        mpVolumeParentView.addSubview(myVolumeView)
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // 現在のデバイスの向きを取得.
        let deviceOrientation: UIInterfaceOrientation!  = UIApplication.sharedApplication().statusBarOrientation
        if deviceOrientation.isLandscape {
            if Int( UIScreen.mainScreen().bounds.size.width) <= 736 {
                selectRateSlider.hidden = true
                selectPitchSlider.hidden = true
            }
        } else {
            selectRateSlider.hidden = false
            selectPitchSlider.hidden = false
        }
    }
    
    // 端末の向きがかわったら呼び出される.
    func onOrientationChange(notification: NSNotification){
        
        let deviceOrientation: UIInterfaceOrientation!  = UIApplication.sharedApplication().statusBarOrientation
        if deviceOrientation.isLandscape {
            if Int( UIScreen.mainScreen().bounds.size.width) <= 736 {
                selectRateSlider.hidden = true
                selectPitchSlider.hidden = true
            }
        } else {
            selectRateSlider.hidden = false
            selectPitchSlider.hidden = false
        }
        
    }
    
    func isSelectedButton(button:UIButton) -> Bool {
        var isSelected = false
        if button.tag == ud.integerForKey("languageID") {
            isSelected = true
        }
        if button.tag == ud.integerForKey("audioButtonID") {
            isSelected = true
        }
        return isSelected
    }
    
    func didChangeSelectedButton(button: UIButton) {
        HilightSelectedButtonBackgroundColor(button)
    }
    
    func HilightSelectedButtonBackgroundColor(button:UIButton) {
        
        switch button {
        case japaneseButton,englishButton :
            for languageButton in languageButtonArray {
                if button == languageButton {
                    languageButton.backgroundColor = UIColor(red: 0.0, green: 0.478431, blue: 1, alpha: 1)
                } else {
                    languageButton.backgroundColor = UIColor.whiteColor()
                }
            }
        case placeLeftPlayButton,placeRightPlayButton :
            for placeButton in placeButtonArray {
                if button == placeButton {
                    placeButton.backgroundColor = UIColor(red: 0.0, green: 0.478431, blue: 1, alpha: 1)
                } else {
                    placeButton.backgroundColor = UIColor.whiteColor()
                }
            }
        default: break
        }
    }
    
    
    
    @IBAction func didTapDecisionButton(sender: AnyObject) {
        saveParams()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveParams() {
        ud.setInteger(langageRadioButtonController.selectedButton()?.tag ?? 10, forKey: "languageID")
        ud.setInteger(placeRadioButtonController.selectedButton()?.tag ?? 20, forKey: "audioButtonID")
        ud.setFloat(selectRateSlider.value, forKey: "rate")
        ud.setFloat(selectPitchSlider.value, forKey: "pitch")
        ud.synchronize()
    }
    
}
