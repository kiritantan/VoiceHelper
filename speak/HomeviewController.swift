//
//  HomeviewController.swift
//  speak
//
//  Created by kiri on 2015/05/08.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import AVFoundation

extension UITextView {
//    func selectTextAtRange(range:NSRange) {
//        let start = self.positionFromPosition(self.beginningOfDocument, offset: range.location)
//        let end   = self.positionFromPosition(start!, offset: range.length)
//        self.selectedTextRange = self.textRangeFromPosition(start, toPosition: end);
//    }
}

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
    }

    func initTextView() {
        textView.delegate = self
        textView.returnKeyType = UIReturnKeyType.Done
        textView.text = placeHolderString
        textView.textColor = UIColor.lightGrayColor()
    }
    
    func initUserDefaults(){
        ud.registerDefaults(["languageID":10,"audioButtonID":20,"rate":0.25,"pitch":1.0,"favoritePhraseArray":[]])
        speaker.registerSpeaker(textView.text)
    }
    
    func DefindLayoutOfAudioButtons() {
        let uiviewWidth  = self.view.frame.width
        let uiviewHeight = self.view.frame.height
        
        for button in [startPauseButton,stopButton] {
            
            button.setTranslatesAutoresizingMaskIntoConstraints(true)
            
            if button.tag == ud.integerForKey("audioButtonID") {
                button.frame = CGRectMake(16, uiviewHeight - uiviewHeight/6 - 70, 2*(uiviewWidth/5), uiviewHeight/6)
            } else {
                button.frame = CGRectMake(uiviewWidth - 2*(uiviewWidth/5) - 16, uiviewHeight - uiviewHeight/6 - 70, 2*(uiviewWidth/5), uiviewHeight/6)
            }
        
        }
    }
    
    @IBAction func didTapModalEditViewButton(sender: AnyObject) {
        speaker.stopSpeak()
        self.performSegueWithIdentifier("modal", sender: self)
    }
    
    
    @IBAction func didTapPlayPauseButton(sender: AnyObject) {
        if speaker.speaker.paused || !speaker.speaker.speaking {
            speaker.startSpeak()
            startPauseButton.setTitle("一時停止", forState: UIControlState.Normal)
        } else {
            speaker.pauseSpeak()
            startPauseButton.setTitle("再開", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func didTapStopButton(sender: AnyObject) {
        speaker.stopSpeak()
        startPauseButton.setTitle("再生", forState: UIControlState.Normal)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if touch.view.tag == 1 {
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
        speaker.registerSpeaker(textView.text)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        startPauseButton.setTitle("再生", forState: UIControlState.Normal)
    }
    
}

