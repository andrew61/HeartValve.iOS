//
//  CameraVC.swift
//  HeartValve
//
//  Created by Tachl on 12/9/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let userManager = UserManager()
    let captureSession = AVCaptureSession()
    let picker = UIImagePickerController()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    
    var captureDevice: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var imageOutput = AVCaptureStillImageOutput()
    
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var pictureBtn: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        picker.delegate = self
        showNavTitle();

        
        questionLabel.text = surveyQuestion?.questionText

//        pictureBtn.layer.cornerRadius = 5
//        pictureBtn.layer.borderWidth = 1
//        pictureBtn.layer.borderColor = UIColor.appBlue().cgColor
        pictureBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        AudioPlayer.speak(questionLabel.text, with: self.synthesizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(true)
        return
    }
    
    func showNavTitle(){
        
        let numberOfViewControllers = self.navigationController?.viewControllers.count
        
        if (numberOfViewControllers == 2){
            self.navigationItem.hidesBackButton = true
        }
        else{
            self.navigationItem.backBarButtonItem?.title = "Previous Question"
        }
    }
    
    @IBAction func replayVoice(_ sender: Any) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        AudioPlayer.speak(surveyQuestion?.questionText, with: self.synthesizer)
    }
    
    @IBAction func takePictureAction(_ sender: Any) {
        
        self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        
        AudioPlayer.speak("Hold the iPhone camera lens steadily over the procedure site. Make sure the procedure site is visible. Firmly tap the white Photo button at the bottom center of the screen. Click the use photo button in the bottom right corner of the screen when the photo has been taken. ", with: self.synthesizer)
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerController.SourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true,completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let hud = Utility.getHUDAdded(to: picker.view, withText: "Loading...")
        hud?.show(true)
        
        let image = info[.originalImage] as! UIImage
        
        //pictureView.contentMode = .scaleAspectFit
        //pictureView.image = image
        
        self.getNextQuestion(self.surveyQuestion?.surveyId as! Int, questionId: self.surveyQuestion?.questionId as! Int, image: image, manager: self.userManager){
            (questionOptions, surveyQuestion) in
            hud?.hide(true)
            print("Post Survey Answers")
            
            self.picker.dismiss(animated: true, completion: {
                
                self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
                self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)

            
            })

        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)

        })
    }
}
