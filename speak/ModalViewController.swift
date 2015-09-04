//
//  ModalViewController.swift
//  speak
//
//  Created by kiri on 2015/07/24.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate{
    func modalDidFinished(modalText: String,textView: UITextView)
}

class ModalViewController: UIViewController,UITextViewDelegate {

    var phrase: String = ""
    var delegate: ModalViewControllerDelegate! = nil
    let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        initTextView()
    }
    
    override func viewWillAppear(animated: Bool) {
        textView.text = phrase
        textView.becomeFirstResponder()
    }
    
    func initTextView() {
        textView.frame = CGRectMake(10, (self.view.frame.size.height)/10, self.view.frame.size.width-20, (self.view.frame.size.height*2)/5)
        textView.layer.borderColor  = UIColor(red: 19/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0).CGColor
        textView.layer.borderWidth  = 2
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFontOfSize(30)
        textView.delegate = self
        textView.returnKeyType = UIReturnKeyType.Done
        self.view.addSubview(self.textView)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if touch.view.tag == 1 {
                textView.resignFirstResponder()
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.endOfDocument)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxLength: Int = 500
        var str = textView.text + text
        if count("\(str)") < maxLength {
            if text != "\n" {
                return true
            }
        }
        if text == "\n" {
            textView.resignFirstResponder()
            self.delegate.modalDidFinished(self.textView.text,textView: self.textView)
        } else {
            AlertBuilder(title: "文字数の上限を超えました", message: "", preferredStyle: .Alert)
                .addAction(title: "OK", style: .Cancel) { Void in
                    
                }
                .build()
                .kam_show(animated: true)
        }
        return false
    }
    
}
