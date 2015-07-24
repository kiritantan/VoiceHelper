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

class FavoriteTableViewController: UITableViewController,AVSpeechSynthesizerDelegate,ModalViewControllerDelegate {
    
    let realm = RLMRealm.defaultRealm()
    let speaker = SpeakModel()
    let modalView = ModalViewController()
    var textArray: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let realm = RLMRealm.defaultRealm()
//        let phrase1 = FavoritePhrase()
//        let phrase2 = FavoritePhrase()
//        let phrase3 = FavoritePhrase()
//        let phrase4 = FavoritePhrase()
//        phrase1.phrase = "おはようございます"
//        phrase2.phrase = "こんにちは"
//        phrase3.phrase = "こんばんわ"
//        phrase4.phrase = "ありがとうございます"
//        
//        realm.transactionWithBlock() {
//            realm.addObject(phrase1)
//            realm.addObject(phrase2)
//            realm.addObject(phrase3)
//            realm.addObject(phrase4)
//        }
//
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.allowsSelectionDuringEditing = true
        speaker.speaker.delegate = self
        self.title = "お気に入りのフレーズ"
        modalView.delegate = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return textArray.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if indexPath.row != textArray.count {
            cell.textLabel?.text = textArray[indexPath.row] as? String
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row != textArray.count {
            speaker.registerSpeaker(textArray[indexPath.row] as! String)
        } else {
            speaker.registerSpeaker("")
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        speaker.speakPhrase()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row != textArray.count {
            return true
        }
        return false
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        if editing {
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCell:")
            self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        } else {
            self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    func addCell(sender: AnyObject) {
        self.presentViewController(modalView, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            realm.beginWriteTransaction()
            realm.deleteObjects(FavoritePhrase.objectsWhere("phrase = '\(textArray[indexPath.row])'"))
            realm.commitWriteTransaction()
            textArray.removeObjectAtIndex(indexPath.row)
            tableView.reloadData()
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    func modalDidFinished(modalText: String){
        var flag = true;
        let results = FavoritePhrase.objectsWhere("phrase = '\(modalText)'")
        for realmBook in results {
            flag = false;
        }
        if flag {
            let phrase = FavoritePhrase()
            phrase.phrase = modalText
            realm.transactionWithBlock() {
                self.realm.addObject(phrase)
            }
            textArray.addObject(modalText)
            tableView.reloadData()
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: textArray.count, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            self.modalView.dismissViewControllerAnimated(true, completion: nil)
        } else {
            AlertBuilder(title: "このフレーズは登録済みです", message: "編集を続けますか?", preferredStyle: .Alert)
                .addAction(title: "いいえ", style: .Cancel) { Void in
                    self.modalView.dismissViewControllerAnimated(true, completion: nil)
                }
                .addAction(title: "はい", style: .Default) { _ in }
                .build()
                .kam_show(animated: true)
        }
    }

}
