//
//  FavoriteTableViewController.swift
//  speak
//
//  Created by kiri on 2015/05/22.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class FavoriteTableViewController: UIViewController,AVSpeechSynthesizerDelegate,ModalViewControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    let realm = try! Realm()
    let speaker = SpeakModel()
    let modalView = ModalViewController()
    var textArray: NSMutableArray = []
    var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
        speaker.speaker.delegate = self
        self.title = "お気に入り"
        modalView.delegate = self
        tableView.rowHeight = 100.0
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTap:")
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        tableView.layer.borderColor  = UIColor(red: 19/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0).CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textArray = []
        for realmPhrase in realm.objects(FavoritePhrase) {
            textArray.addObject("\(realmPhrase.phrase)")
        }
        tableView.reloadData()
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        speaker.stopSpeak()
    }
    
    func didLongTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            return
        }
        let p = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(p)
        let cell = tableView.cellForRowAtIndexPath(indexPath!)
        if indexPath?.row < textArray.count {
            try! realm.write{
                self.realm.delete(self.realm.objects(FavoritePhrase).filter("phrase = '\(self.textArray[indexPath!.row])'"))
            }
            modalView.phrase = textArray[indexPath!.row] as! String
            textArray.removeObjectAtIndex(indexPath!.row)
            self.presentViewController(modalView, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapAddCellButton(sender: AnyObject) {
        modalView.phrase = ""
        self.presentViewController(modalView, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textArray.count + 1
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        if indexPath.row != textArray.count {
            cell.textLabel?.text = textArray[indexPath.row] as? String
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row != textArray.count {
            let ud = NSUserDefaults.standardUserDefaults()
            let pattern = "([a-zA-Z0-9+-.,!@#$%^&*()\\[\\];\\/|<>\"'?\\\\= \\n]+)"
            let replaceString = (textArray[indexPath.row] as! String).stringByReplacingOccurrencesOfString(pattern, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            var languageID = 10
            if replaceString.isEmpty {
                languageID = 11
            }
            ud.setInteger(languageID, forKey: "languageID")
            ud.synchronize()
            speaker.registerSpeaker(textArray[indexPath.row] as! String)
        } else {
            speaker.registerSpeaker("")
        }
        selectedIndexPath = indexPath
        return indexPath
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        speaker.speakPhrase()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row != textArray.count {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            try! realm.write{
                self.realm.delete(self.realm.objects(FavoritePhrase).filter("phrase = '\(self.textArray[indexPath.row])'"))
            }
            textArray.removeObjectAtIndex(indexPath.row)
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                tableView.reloadData()
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: self.textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            })
            
        }
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count + 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    func modalDidFinished(modalText: String, textView: UITextView) {
        var flag = true;
        let results = realm.objects(FavoritePhrase).filter("phrase = '\(modalText)'")
        for _ in results {
            flag = false
        }
        if flag {
            let phrase = FavoritePhrase()
            if modalText != "" {
                phrase.phrase = modalText
                try! realm.write{
                    self.realm.add(phrase)
                }
                textArray.addObject(modalText)
                tableView.reloadData()
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
                tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: textArray.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
            self.modalView.dismissViewControllerAnimated(true, completion: nil)
        } else {
            AlertBuilder(title: "このフレーズは登録済みです", message: "編集を続けますか?", preferredStyle: .Alert)
                .addAction("いいえ", style: .Cancel) { Void in
                    self.modalView.dismissViewControllerAnimated(true, completion: nil)
                }
                .addAction("はい", style: .Default) { Void in
                    textView.becomeFirstResponder()
                }
                .build()
                .kam_show(true)
        }
    }

}
