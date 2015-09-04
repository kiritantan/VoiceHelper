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
    
    @IBOutlet var placeLeftPlayButton: UIButton!
    @IBOutlet var placeRightPlayButton: UIButton!
    @IBOutlet var selectRateSlider: UISlider!
    @IBOutlet var selectPitchSlider: UISlider!
    @IBOutlet var mpVolumeViewParentView: UIView!
    
    var langageRadioButtonController = SSRadioButtonsController()
    var placeRadioButtonController = SSRadioButtonsController()
    var placeButtonArray:[UIButton]!    = nil
    let myVolumeView = MPVolumeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"
        placeButtonArray    = [placeLeftPlayButton,placeRightPlayButton]
        placeRadioButtonController.setButtonsArray(placeButtonArray)
        placeRadioButtonController.delegate   = self
        for placeButton in placeButtonArray {
            if isSelectedButton(placeButton) {
                placeRadioButtonController.pressed(placeButton)
            }
        }
        selectRateSlider.value = ud.floatForKey("rate")
        selectPitchSlider.value = ud.floatForKey("pitch")
        mpVolumeViewParentView.addSubview(myVolumeView)
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        myVolumeView.frame = mpVolumeViewParentView.bounds
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveParams()
        super.viewWillDisappear(animated)
    }
    
    func onOrientationChange(notification: NSNotification){
        UIView.animateWithDuration(0.40, animations:{() -> Void in
            self.myVolumeView.frame = self.mpVolumeViewParentView.bounds
        })
    }
    
    func isSelectedButton(button:UIButton) -> Bool {
        var isSelected = false
        if button.tag == ud.integerForKey("audioButtonID") {
            isSelected = true
        }
        return isSelected
    }
    
    func didChangeSelectedButton(button: UIButton) {
        HilightSelectedButtonBackgroundColor(button)
    }
    
    func HilightSelectedButtonBackgroundColor(button:UIButton) {
        for placeButton in placeButtonArray {
            if button == placeButton {
                placeButton.backgroundColor = UIColor(red: 0.0, green: 0.478431, blue: 1, alpha: 1)
            } else {
                placeButton.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    func saveParams() {
        ud.setInteger(placeRadioButtonController.selectedButton()?.tag ?? 20, forKey: "audioButtonID")
        ud.setFloat(selectRateSlider.value, forKey: "rate")
        ud.setFloat(selectPitchSlider.value, forKey: "pitch")
        ud.synchronize()
    }
    
}
