//
//  FavoriteTableViewController.swift
//  speak
//
//  Created by kiri on 2015/05/22.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import UIKit
import AVFoundation

class FavoriteTableViewController: UITableViewController,AVSpeechSynthesizerDelegate {
    
    let ud = NSUserDefaults.standardUserDefaults()
    let speaker = SpeakModel()
    var textArray: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.allowsSelectionDuringEditing = true
        speaker.speaker.delegate = self
        self.title = "お気に入りのフレーズ"
        textArray = ["おはようございます","こんにちは","こんばんわ","ありがとうございます"]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        textArray.addObject("add Cell")
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            textArray.removeObjectAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }

}
