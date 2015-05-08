//
//  HomeviewController.swift
//  speak
//
//  Created by kiri on 2015/05/08.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

class HomeviewController: UIViewController,UITextViewDelegate {

    let ud = NSUserDefaults.standardUserDefaults()
    let speaker = SpeakModel()
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "speak"
        initTextView()
        initUserDefaults()
    }

    override func viewWillAppear(animated: Bool) {
        speaker.registerSpeaker(textView.text)
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
        ud.registerDefaults(["languageID":0,"rate":0.25,"pitch":1.0])
        speaker.registerSpeaker(textView.text)
    }
    
    @IBAction func didTapModalEditViewButton(sender: AnyObject) {
        speaker.stopSpeak()
        self.performSegueWithIdentifier("modal", sender: self)
    }
    
    
    @IBAction func didTapPlayButton(sender: AnyObject) {
        speaker.startSpeak()
    }
    
    @IBAction func didTapPauseButton(sender: AnyObject) {
        speaker.pauseSpeak()
    }
    
    @IBAction func didTapStopButton(sender: AnyObject) {
        speaker.stopSpeak()
    }
    
    @IBAction func didTapEditTextViewButton(sender: AnyObject) {
        speaker.stopSpeak()
        self.textView.becomeFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        textView.resignFirstResponder()
        speaker.registerSpeaker(textView.text)
        return false
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    
}

