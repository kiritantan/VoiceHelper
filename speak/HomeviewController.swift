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

    let ud = NSUserDefaults.standardUserDefaults()
    let speaker = SpeakModel()
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var startPauseButton: FrameBorderButton!
    @IBOutlet var stopButton: FrameBorderButton!
    @IBOutlet var deleteTextButton: FrameBorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "ボイスヘルパー"
        speaker.speaker.delegate = self
//        textView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0)
        initTextView()
        initUserDefaults()
    }

    override func viewWillAppear(animated: Bool) {
        speaker.registerSpeaker(textView.text)
        DefindLayoutOfAudioButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initTextView() {
        textView.delegate = self
        textView.returnKeyType = UIReturnKeyType.Done
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
                endEditOfTextView()
            }
        }
    }
    
    @IBAction func didTapDeleteTextButton(sender: AnyObject) {
        textView.text = ""
        speaker.registerSpeaker(textView.text)
    }
    func textViewDidBeginEditing(textView: UITextView) {
        speaker.stopSpeak()
        self.textView.becomeFirstResponder()
        deleteTextButton.hidden = true;
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        endEditOfTextView()
        return false
    }
    
    func endEditOfTextView() {
        deleteTextButton.hidden = false
        textView.resignFirstResponder()
        speaker.registerSpeaker(textView.text)
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        startPauseButton.setTitle("再生", forState: UIControlState.Normal)
    }
    
}

