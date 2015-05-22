//
//  speakModel.swift
//  speak
//
//  Created by kiri on 2015/05/09.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

import Foundation
import AVFoundation

class SpeakModel: NSObject {
    
    let ud = NSUserDefaults.standardUserDefaults()
    var speaker = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance()
    
    func registerSpeaker(text:String) {
        utterance = AVSpeechUtterance(string:text)
        switch ud.integerForKey("languageID") {
        case 10:
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        case 11:
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        default:
            break
        }
        utterance.rate = ud.floatForKey("rate")
        utterance.pitchMultiplier = ud.floatForKey("pitch")
    }
    
    func startSpeak() {
        if speaker.paused {
            speaker.continueSpeaking()
        } else if !self.speaker.speaking {
            speaker.speakUtterance(utterance)
        }
    }
    
    func pauseSpeak() {
        speaker.pauseSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    }
    
    func stopSpeak() {
        speaker.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    }
    
    func speakPhrase() {
        speaker.speakUtterance(utterance)
    }
    
}