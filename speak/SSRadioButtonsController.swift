//
//  SSRadioButtonsController.swift
//  speak
//
//  Created by kiri on 2015/05/21.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import Foundation
import UIKit

protocol SSRadioButtonsDelegate: class {
    func didChangeSelectedButton(button:UIButton)
}

class SSRadioButtonsController :NSObject
{
    private var buttonsArray = [UIButton]()
    private weak var currentSelectedButton:UIButton? = nil
    weak var delegate:SSRadioButtonsDelegate? = nil
    override init() {
    }
    
    func addButton(aButton:UIButton)
    {
        buttonsArray.append(aButton)
        aButton.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func removeButton(aButton:UIButton)
    {
        var iteration = 0
        var iteratingButton:UIButton? = nil
        for(iteration; iteration<buttonsArray.count;iteration++)
        {
            iteratingButton = buttonsArray[iteration]
            if(iteratingButton == aButton)
            {
                break
            }
            else
            {
                iteratingButton = nil
            }
        }
        if(iteratingButton != nil)
        {
            buttonsArray.removeAtIndex(iteration)
            iteratingButton!.removeTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func setButtonsArray(aButtonsArray:[UIButton])
    {
        for aButton in aButtonsArray
        {
            aButton.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        buttonsArray = aButtonsArray
    }
    
    func pressed(sender:UIButton)
    {
        for aButton in buttonsArray
        {
            if aButton != sender
            {
                aButton.selected = false
            }
        }
        sender.selected = true
        currentSelectedButton = sender
        delegate!.didChangeSelectedButton(sender)
    }
    
    func selectedButton() ->UIButton?
        
    {
        return currentSelectedButton
    }
}