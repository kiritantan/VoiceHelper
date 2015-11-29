//
//  HomeviewController.swift
//  speak
//
//  Created by kiri on 2015/05/08.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class HomeviewController: UIViewController,UITextViewDelegate,AVSpeechSynthesizerDelegate {

    let placeHolderString = "入力欄"
    let ud = NSUserDefaults.standardUserDefaults()
    let speaker = SpeakModel()
    let realm = try! Realm()
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var startPauseButton: FrameBorderButton!
    @IBOutlet var stopButton: FrameBorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "会話"
        speaker.speaker.delegate = self
        textView.layer.borderColor  = UIColor(red: 19/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0).CGColor
        initTextView()
        initUserDefaults()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try audioSession.setActive(true)
        } catch _ {
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.updateSpeakerState()
            self.DefindLayoutOfAudioButtons()
        })
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        speaker.stopSpeak()
    }

    func initTextView() {
        textView.delegate = self
        textView.returnKeyType = UIReturnKeyType.Done
        textView.text = placeHolderString
        textView.textColor = UIColor.lightGrayColor()
    }
    
    func initUserDefaults(){
        ud.registerDefaults(["languageID":10,"audioButtonID":20,"rate":0.25,"pitch":1.0,"favoritePhraseArray":[]])
        updateSpeakerState()
    }
    
    func updateSpeakerState() {
        let ud = NSUserDefaults.standardUserDefaults()
        let pattern = "([a-zA-Z0-9+-.,!@#$%^&*()\\[\\];\\/|<>\"'?\\\\= \\n]+)"
        let replaceString = textView.text.stringByReplacingOccurrencesOfString(pattern, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        var languageID = 10
        if replaceString.isEmpty {
            languageID = 11
        }
        ud.setInteger(languageID, forKey: "languageID")
        ud.synchronize()
        speaker.registerSpeaker(textView.text)
    }
    
    func DefindLayoutOfAudioButtons() {
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
    
    @IBAction func didTapRegisterPhraseButton(sender: UIButton) {
        var flag = true;
        let results = realm.objects(FavoritePhrase).filter("phrase = '\(textView.text)'")
        for _ in results {
            flag = false
        }
        if flag {
            if textView.textColor == UIColor.lightGrayColor() {
                return
            }
            let phrase = FavoritePhrase()
            if textView.text != "" {
                phrase.phrase = textView.text
                try! realm.write{
                    self.realm.add(phrase)
                }
                AlertBuilder(title: "お気に入りに登録しました", message: "", preferredStyle: .Alert)
                    .addAction("OK", style: .Cancel) { Void in
                        
                    }
                    .build()
                    .kam_show(true)
            }
        } else {
            if textView.textColor != UIColor.lightGrayColor() {
                AlertBuilder(title: "このフレーズは登録済みです", message: "", preferredStyle: .Alert)
                    .addAction("OK", style: .Cancel) { Void in
                        
                    }
                    .build()
                    .kam_show(true)
            }
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if touch.view!.tag == 1 {
                textView.resignFirstResponder()
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
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderString
            textView.textColor = UIColor.lightGrayColor()
        }
        updateSpeakerState()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxLength: Int = 500
        let str = textView.text + text
        if "\(str)".characters.count < maxLength {
            if text != "\n" {
                return true
            }
        }
        if text == "\n" {
            textView.resignFirstResponder()
        } else {
            AlertBuilder(title: "文字数の上限を超えました", message: "", preferredStyle: .Alert)
                .addAction("OK", style: .Cancel) { Void in
                    
                }
                .build()
                .kam_show(true)
        }
        return false
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        for button in [startPauseButton,stopButton] {
            if button.tag == ud.integerForKey("audioButtonID") {
                button.setTitle("再生", forState: .Normal)
                button.addTarget(self, action: "didTapPlayPauseButton:", forControlEvents: .TouchUpInside)
            }
        }
    }
    
}

