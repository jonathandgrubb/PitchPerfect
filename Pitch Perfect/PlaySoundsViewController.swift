//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jonathan Grubb on 6/22/15.
//  Copyright (c) 2015 Jonathan Grubb. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // -- AVAudioPlayer approach for rate playback --
        // create instance of AVAudioPlayer using file path
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        // allow rate adjustment
        audioPlayer.enableRate = true
        
        // -- AVAudioEngine / AVAudioPlayerNode / AVAudioUnitTimePitch approach for pitch shifting playback --
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowly(sender: UIButton) {
        playAudio(0.5)
    }

    @IBAction func playQuickly(sender: UIButton) {
        playAudio(1.5)
    }
    
    @IBAction func playChipmunk(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playVader(sender: UIButton) {
        playAudioWithVariablePitch(-500)
    }
    
    @IBAction func playReverb(sender: UIButton) {
        playAudioWithReverb(50.0)
    }
    
    @IBAction func stopPlayback(sender: UIButton) {
        stopAndResetAudio()
    }
    
    func playAudio(speed: Float) {
        // good practice to stop the audioplayer first
        stopAndResetAudio()
        
        // alter the playback speed
        audioPlayer.rate = speed
        
        // play the audio
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        // good practice to stop the audioplayer first
        stopAndResetAudio()
        
        // attach audioPlayerNode to audioEngine
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // set pitch and attach changePitchEffect to audioEngine
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        // connect audioPlayerNode -> changePitchEffect -> speakers
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // schedule a playback time for audioFile
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // start audioEngine
        audioEngine.startAndReturnError(nil)
        
        // play the file the the effects
        audioPlayerNode.play()
    }
    
    func playAudioWithReverb(wetDryMix: Float) {
        // good practice to stop the audioplayer first
        stopAndResetAudio()
        
        // attach audioPlayerNode to audioEngine
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // set reverb and attach addReverbEffect to audioEngine
        var addReverbEffect = AVAudioUnitReverb()
        addReverbEffect.wetDryMix = wetDryMix
        audioEngine.attachNode(addReverbEffect)
        
        // connect audioPlayerNode -> changePitchEffect -> speakers
        audioEngine.connect(audioPlayerNode, to: addReverbEffect, format: nil)
        audioEngine.connect(addReverbEffect, to: audioEngine.outputNode, format: nil)
        
        // schedule a playback time for audioFile
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // start audioEngine
        audioEngine.startAndReturnError(nil)
        
        // play the file the the effects
        audioPlayerNode.play()
    }
    
    func stopAndResetAudio() {
        // stop and reset audioPlayer (slow and fast effects)
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        
        // stop and reset audioEngine (pitch shifted effects)
        audioEngine.stop()
        audioEngine.reset()
    }
}
