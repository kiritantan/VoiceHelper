//
//  HomeviewController.swift
//  speak
//
//  Created by kiri on 2015/05/08.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import AVFoundation

class HomeviewController: UIViewController,UITextViewDelegate,AVSpeechSynthesizerDelegate {

    let placeHolderString = "入力欄"
    let ud = NSUserDefaults.standardUserDefaults()
    let speaker = SpeakModel()
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var startPauseButton: FrameBorderButton!
    @IBOutlet var stopButton: FrameBorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speaker.speaker.delegate = self
        initTextView()
        initUserDefaults()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        speaker.registerSpeaker(textView.text)
        DefindLayoutOfAudioButtons()
        switch ud.integerForKey("languageID") {
        case 10:
            self.title = "日本語モード"
        case 11:
            self.title = "英語モード"
        default:
            break
        }
        println(UIDevice.currentDevice().model)
    }
    
    override func viewWillDisappear(animated: Bool) {
        speaker.stopSpeak()
    }

    func initTextView() {
        textView.delegate = self
        textView.returnKeyType = UIReturnKeyType.Done
        textView.text = placeHolderString
        textView.textColor = UIColor.lightGrayColor()
    }
    
    func initUserDefaults(){
        ud.registerDefaults(["languageID":10,"audioButtonID":21,"rate":0.25,"pitch":1.0,"favoritePhraseArray":[]])
        speaker.registerSpeaker(textView.text)
    }
    
    func DefindLayoutOfAudioButtons() {
        if UIDevice.currentDevice().model == "iPad" {
            for button in [startPauseButton,stopButton] {
                button.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                if button.tag == ud.integerForKey("audioButtonID") {
                    button.setTitle("再生", forState: .Normal)
                    button.addTarget(self, action: "didTapPlayPauseButton:", forControlEvents: .TouchUpInside)
                } else {
                    button.setTitle("停止", forState: .Normal)
                    button.addTarget(self, action: "didTapStopButton:", forControlEvents: .TouchUpInside)
                }
            }
        } else {
            for button in [startPauseButton,stopButton] {
                button.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                if button.tag != ud.integerForKey("audioButtonID") {
                    button.setTitle("再生", forState: .Normal)
                    button.addTarget(self, action: "didTapPlayPauseButton:", forControlEvents: .TouchUpInside)
                } else {
                    button.setTitle("停止", forState: .Normal)
                    button.addTarget(self, action: "didTapStopButton:", forControlEvents: .TouchUpInside)
                }
            }
        }
        
    }
    
    @IBAction func didTapPlayPauseButton(sender: AnyObject) {
        let button = sender as! UIButton
        if speaker.speaker.paused || !speaker.speaker.speaking {
            speaker.startSpeak()
            button.setTitle("一時停止", forState: UIControlState.Normal)
        } else {
            speaker.pauseSpeak()
            button.setTitle("再開", forState: UIControlState.Normal)
        }
    }
    
    func didTapStopButton(sender: AnyObject) {
        let button = sender as! UIButton
        for myButton in [startPauseButton,stopButton] {
            if myButton.tag != button.tag {
                myButton.setTitle("再生", forState: .Normal)
            }
        }
        speaker.stopSpeak()
    }
    
    @IBAction func didTapModalEditViewButton(sender: AnyObject) {
        speaker.stopSpeak()
        self.performSegueWithIdentifier("modal", sender: self)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if touch.view.tag == 1 {
                textView.resignFirstResponder()
                startPauseButton.hidden = false
                stopButton.hidden = false
            }
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.endOfDocument)
        })
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        speaker.stopSpeak()
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        startPauseButton.hidden = true
        stopButton.hidden = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderString
            textView.textColor = UIColor.lightGrayColor()
        }
        speaker.registerSpeaker(textView.text)
        startPauseButton.hidden = false
        stopButton.hidden = false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        if UIDevice.currentDevice().model == "iPad" {
            for button in [startPauseButton,stopButton] {
                if button.tag == ud.integerForKey("audioButtonID") {
                    button.setTitle("再生", forState: .Normal)
                }
            }
        } else {
            for button in [startPauseButton,stopButton] {
                if button.tag != ud.integerForKey("audioButtonID") {
                    button.setTitle("再生", forState: .Normal)
                }
            }
        }
    }
    
}

