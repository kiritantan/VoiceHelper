//
//  ModalViewController.swift
//  speak
//
//  Created by kiri on 2015/07/24.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate{
    func modalDidFinished(modalText: String)
}

class ModalViewController: UIViewController,UITextViewDelegate {

    var delegate: ModalViewControllerDelegate! = nil
    let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        initTextView()
    }
    
    override func viewWillAppear(animated: Bool) {
        textView.text = ""
        textView.becomeFirstResponder()
    }
    
    func initTextView() {
        textView.frame = CGRectMake(10, (self.view.frame.size.height)/10, self.view.frame.size.width-20, (self.view.frame.size.height*2)/5)
        textView.layer.borderColor  = UIColor(red: 19/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0).CGColor
        textView.layer.borderWidth  = 2
        textView.layer.cornerRadius = 10
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
    
    func textViewDidEndEditing(textView: UITextView) {
        self.delegate.modalDidFinished(self.textView.text)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
}
