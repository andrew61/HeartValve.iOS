//
//  ContinueSurveyVC.swift
//  HeartValve
//
//  Created by Tachl on 12/13/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation
import UIKit

class ContinueSurveyVC: UIViewController{
    
    let userManager = UserManager()

    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        if(JNKeychain.loadValue(forKey: "isDailyAssessmentSurvey") != nil){
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.updateDailyAssessment(withStep: 2)
        }
        
        
        self.getQuestion(3, manager: self.userManager){
            (questionOptions, surveyQuestion) in
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    func back(sender: UIBarButtonItem) {
        
        print("Display alert here")
        print("Display alert here")
        
        let numberOfViewControllers = self.navigationController?.viewControllers.count
        print(numberOfViewControllers as Any)
        
        if (numberOfViewControllers == 1){
            print("Display alert here")
            print("Display alert here")
            
        }
        else{
            print("navigationController")
            self.navigationController?.popViewController(animated: true);
            
        }
        
        
    }
}
