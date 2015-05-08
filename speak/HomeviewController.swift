//
//  HomeviewController.swift
//  speak
//
//  Created by kiri on 2015/05/08.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

class HomeviewController: UIViewController,UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initTextView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func initTextView() {
        textView.delegate = self
        textView.userInteractionEnabled = false
        textView.returnKeyType = UIReturnKeyType.Done
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.textView.resignFirstResponder()
    }
    
    @IBAction func didTapEditTextViewButton(sender: AnyObject) {
        self.textView.becomeFirstResponder()
    }
    
    
}

