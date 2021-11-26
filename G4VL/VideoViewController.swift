//
//  VideoViewController.swift
//  G4VL
//
//  Created by Michael Miller on 29/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreData
import Photos
import Bugsnag

protocol VideoDelegate {
    func updateVideos(videos:[VideoAppraisalEntry.Video])
}
class VideoViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, PhotoCellDelegate, UINavigationControllerDelegate {
    
    var appManager = AppManager.sharedInstance
    var videoDelegate : VideoDelegate?
    var videos : [VideoAppraisalEntry.Video] = []
    var fromLibrary = true
    var pickup = true
    
    @IBOutlet var collView : UICollectionView!
     
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return videos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.delegate = self
        
        let path = OfflineFolderStructure.getVideoPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!, pickup: pickup) + "/" + videos[indexPath.row].videoName!

        cell.filename = videos[indexPath.row].videoName!
        cell.imageView.image  = generateThumbnailFrom(path: path)
        
        return cell
    }
    
    
    func generateThumbnailFrom(path:String)->UIImage? {
        
        let asset = AVURLAsset(url: URL(string:path)!)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "generateThumbnailFrom"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
        return nil
        
    }
    
    
    @IBAction func videoSource() {
        
        let alert = UIAlertController(title: nil, message: "Choose video source", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Take Video", style: .default, handler: {
            action in
            
            self.fromLibrary = false
            let cameraController = UIImagePickerController()
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
                return
            }
            
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String]
            cameraController.cameraCaptureMode = .video
            cameraController.videoQuality = .typeMedium
            cameraController.allowsEditing = false
            cameraController.delegate = self
            
            DispatchQueue.main.async {
                self.present(cameraController, animated: true, completion: nil)
            }
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "From Library", style: .default, handler: {
            action in
            
            
            self.fromLibrary = true
            let cameraController = UIImagePickerController()
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
                return
            }
            
            cameraController.sourceType = .photoLibrary
            cameraController.mediaTypes = [kUTTypeMovie as String]
            cameraController.allowsEditing = false
            cameraController.delegate = self
            
            DispatchQueue.main.async {
                self.present(cameraController, animated: true, completion: nil)
            }
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func removeImageWithFilename(filename: String) {
        
        let videos = self.videos.filter {
            return $0.videoName == filename
        }
        
        if videos.count != 0 {
            
            let index = self.videos.index(of: videos.first!)
            
            if index != nil {
                self.videos.remove(at: index!)
                collView.reloadData()
                self.videoDelegate?.updateVideos(videos: self.videos)
            }
        }
    }
    
    
    //MARK: IMagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    //}@objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.view.isUserInteractionEnabled = false
        
        self.view.makeToastActivity(.center)
        
        
        
        
        let guid = GUID.generate()
        
        let path = OfflineFolderStructure.getVideoPath(driverID: appManager.currentUser!.driverID!, jobID: appManager.currentJobAppraisal!.jobID!,pickup: pickup) + "/\(guid).MOV"
        
        if fromLibrary {
            
            let refURL = info[UIImagePickerController.InfoKey.referenceURL] == nil ? info[UIImagePickerController.InfoKey.mediaURL] as! NSURL : info[UIImagePickerController.InfoKey.referenceURL] as! NSURL
            
            
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [refURL as URL], options:nil)
            if let phAsset = fetchResult.firstObject {
                PHImageManager.default().requestAVAsset(forVideo: phAsset, options: PHVideoRequestOptions(), resultHandler: { (asset, audioMix, inf) -> Void in
                    
                    if let asset = asset as? AVURLAsset {
                        
                        do {
                            let videoData = try Data(contentsOf: asset.url)
                            let videoURL = URL(string:path)!
                            try videoData.write(to: videoURL, options: Data.WritingOptions.atomicWrite)
                            
                            let video = VideoAppraisalEntry.Video(videoName: nil, vimeoLink: nil)
                            video.videoName = "\(guid).MOV"
                            self.videos.append(video)
                            
                            
                            self.videoDelegate?.updateVideos(videos: self.videos)
                            
                            DispatchQueue.main.async {
                                self.collView.reloadData()
                                self.view.isUserInteractionEnabled = true
                                self.view.hideToastActivity()
                            }
                            
                            
                        }
                        catch {
                            print(error.localizedDescription)
                            DispatchQueue.main.async {
                                self.view.isUserInteractionEnabled = true
                                self.view.hideToastActivity()
                                self.errrorSaving()
                            }
                            let exception = NSException(name:NSExceptionName(rawValue: "imagePickerController"),
                                                        reason:"\(error.localizedDescription)",
                                userInfo:nil)
                            Bugsnag.notify(exception)
                        }
                        
                    }
                    else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.view.isUserInteractionEnabled = true
                            let  alert = UIAlertController(title: "Error", message: "This asset is invalid", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                action in
                                
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.view.hideToastActivity()
                    
                    let  alert = UIAlertController(title: "Error", message: "Something went wrong, try again.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                        action in
                        
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
        else {
           
            if let filePath = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
                
                UISaveVideoAtPathToSavedPhotosAlbum(filePath.path!, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                
                
                
                do {
                    let videoData = try Data(contentsOf: filePath as URL)
                    let videoURL = URL(string:path)!
                    try videoData.write(to: videoURL, options: Data.WritingOptions.atomicWrite)
                    
                    let video = VideoAppraisalEntry.Video(videoName: nil, vimeoLink: nil)
                    video.videoName = "\(guid).MOV"
                    self.videos.append(video)
                    
                    self.videoDelegate?.updateVideos(videos: self.videos)
                    
                    DispatchQueue.main.async {
                        self.collView.reloadData()
                        self.view.isUserInteractionEnabled = true
                        self.view.hideToastActivity()
                    }
                }
                catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.view.hideToastActivity()
                        self.errrorSaving()
                    }
                    let exception = NSException(name:NSExceptionName(rawValue: "imagePickerController"),
                                                reason:"\(error.localizedDescription)",
                        userInfo:nil)
                    Bugsnag.notify(exception)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.view.hideToastActivity()
                    
                    let  alert = UIAlertController(title: "Error", message: "Something went wrong, try again.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                        action in
                        
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            
        }
            
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        if error != nil {
            
            print("Error Saving Live Video: \(error!.localizedDescription)")
            
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.view.hideToastActivity()
                
                let  alert = UIAlertController(title: "Error", message: "Something went wrong, try again.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    action in
                    
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            
        }
        
    }
    
   

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.view.isUserInteractionEnabled = true
        self.view.hideToastActivity()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func errrorSaving() {
        self.view.hideToastActivity()
        self.view.isUserInteractionEnabled = true
        let  alert = UIAlertController(title: "Error", message: "Video could not be saved, make sure you have enough memory on your device. Videos are removed when the job is finished.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}
