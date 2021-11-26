//
//  VideoAppraisalViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 27/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreData
import Photos

class VideoAppraisalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VideoDelegate {

    var appManager = AppManager.sharedInstance
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    @IBOutlet var lblVideoCount : UILabel!
    
    @IBOutlet var btnConfirm : UIButton!
    
    var pickup = true
    var entry : VideoAppraisalEntry?
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if jobAppraisal.videoAppraisal == nil {
            jobAppraisal.videoAppraisal = VideoAppraisal()
        }
        
        if pickup {
            entry = jobAppraisal.videoAppraisal!.pickup
        }
        else {
            entry = jobAppraisal.videoAppraisal!.dropoff
        }
        
            if entry!.videos.count == 1 {
                lblVideoCount.text = "\(entry!.videos.count) video added"
            }
            else {
                lblVideoCount.text = "\(entry!.videos.count) videos added"
            }
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func saveChanges() {
        
       
            if entry!.videos.count != 0 {
                
                
                if jobAppraisal.videoAppraisal == nil {
                    jobAppraisal.videoAppraisal = VideoAppraisal()
                }
                
                
                entry!.complete = true
                
                JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                
                self.back()
            }
            else if entry!.complete {
                //if no videos  but marked as complete i.e there were videos but it was edited and videos removed
                //mark as incomplete
                entry!.complete = false
                
                JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                
                self.back()
                
            }
        
        

    }
    
    @IBAction func moveToVideos() {
        self.performSegue(withIdentifier: "to_videos", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_videos" {
            let vc = segue.destination as! VideoViewController
            vc.videoDelegate = self
            vc.pickup = pickup
               vc.videos = entry!.videos
            
        }
        
    }

    func updateVideos(videos: [VideoAppraisalEntry.Video]) {
        
        DispatchQueue.main.async {
            
                self.entry!.videos = videos
                
                if self.entry!.videos.count == 1 {
                    self.lblVideoCount.text = "\(videos.count) video added"
                }
                else {
                    self.lblVideoCount.text = "\(videos.count) videos added"
                }
                
            
            
            JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
            
            if videos.count > 1 {
                self.btnConfirm.isHidden = false
            }
            else {
                self.btnConfirm.isHidden = false
            }
        }
        
        
    }
    
    

    

}
