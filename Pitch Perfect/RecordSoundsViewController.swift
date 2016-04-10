//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jonathan Grubb on 6/11/15.
//  Copyright (c) 2015 Jonathan Grubb. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        readyToRecord(nil)
    }

    @IBAction func recordAudio(sender: UIButton) {
        recordingInProgress.text = "recording in progress"
        stopButton.hidden = false
        recordButton.enabled = false
        errorMessage.hidden = true
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        // use the same file name each time
        let recordingName = "currentRecording.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecordAudio(sender: UIButton) {
        recordingInProgress.text = "Saving..."
        
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    func readyToRecord(showLastError: String?) {
        stopButton.hidden = true
        recordButton.enabled = true
        recordingInProgress.text = "Tap To Record"
        
        if let unwrappedShowLastError = showLastError {
            errorMessage.text = showLastError
            errorMessage.hidden = false
        } else {
            errorMessage.hidden = true
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            // save recorded audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            // move to the next scene (perform segue)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            readyToRecord("recording was not successful")
        }
    }
}

