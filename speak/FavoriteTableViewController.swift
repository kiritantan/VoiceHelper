//
//  FavoriteTableViewController.swift
//  speak
//
//  Created by kiri on 2015/05/22.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import AVFoundation
import Realm

class FavoriteTableViewController: UIViewController,AVSpeechSynthesizerDelegate,ModalViewControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    let realm = RLMRealm.defaultRealm()
    let speaker = SpeakModel()
    let modalView = ModalViewController()
    var textArray: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
        speaker.speaker.delegate = self
        self.title = "お気に入り"
        modalView.delegate = self
        tableView.rowHeight = 100.0
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTap:")
        tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textArray = []
        for realmPhrase in FavoritePhrase.allObjects() {
            textArray.addObject("\((realmPhrase as! FavoritePhrase).phrase)")
        }
        tableView.reloadData()
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    func didLongTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            return
        }
        let p = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(p)
        let cell = tableView.cellForRowAtIndexPath(indexPath!)
        if indexPath?.row < textArray.count {
            realm.beginWriteTransaction()
            realm.deleteObjects(FavoritePhrase.objectsWhere("phrase = '\(textArray[indexPath!.row])'"))
            realm.commitWriteTransaction()
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
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
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
            realm.beginWriteTransaction()
            realm.deleteObjects(FavoritePhrase.objectsWhere("phrase = '\(textArray[indexPath.row])'"))
            realm.commitWriteTransaction()
            textArray.removeObjectAtIndex(indexPath.row)
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                tableView.reloadData()
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: self.textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            })
            
        }
    }
    
    func modalDidFinished(modalText: String, textView: UITextView) {
        var flag = true;
        let results = FavoritePhrase.objectsWhere("phrase = '\(modalText)'")
        for realmBook in results {
            flag = false
        }
        if flag {
            let phrase = FavoritePhrase()
            if modalText != "" {
                phrase.phrase = modalText
                realm.transactionWithBlock() {
                    self.realm.addObject(phrase)
                }
                textArray.addObject(modalText)
                tableView.reloadData()
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
                tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: textArray.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
            self.modalView.dismissViewControllerAnimated(true, completion: nil)
        } else {
            AlertBuilder(title: "このフレーズは登録済みです", message: "編集を続けますか?", preferredStyle: .Alert)
                .addAction(title: "いいえ", style: .Cancel) { Void in
                    self.modalView.dismissViewControllerAnimated(true, completion: nil)
                }
                .addAction(title: "はい", style: .Default) { Void in
                    textView.becomeFirstResponder()
                }
                .build()
                .kam_show(animated: true)
        }
    }

}
