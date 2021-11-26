//
//  PhotoViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 20/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import ImagePicker
import Bugsnag
import Uploadcare
import Photos

protocol PhotoDelegate {
    func updatePhotos(photoNames:[String])
    func updatePhotos(photoNames:[String],uploadCare:[String])
}

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ImagePickerDelegate, PhotoCellDelegate {
    
    var photoDelegate : PhotoDelegate?
    var photoNames : [String] = []
    var uploadCareURL:[String] = []
    
    @IBOutlet var collView : UICollectionView!
    var pickup = true
    
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoNames.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.delegate = self
        
        let path = OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!,pickup: pickup) + "/" + photoNames[indexPath.row]
        
        
        
        cell.filename = photoNames[indexPath.row]
        
        cell.imageView.image  = UIImage(contentsOfFile: path.replacingOccurrences(of: "file://", with: ""))
        
        return cell
    }
    
    
    
    @IBAction func showPhotoOptions() {
        let configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.allowMultiplePhotoSelection = false
        configuration.canRotateCamera = true
        configuration.cancelButtonTitle = "Cancel"
        
        let imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        addImagesToArray(images)
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        addImagesToArray(images)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func addImagesToArray(_ images : [UIImage]) {
        
        
        for image in images {
            
            let filename = "\(AppManager.sharedInstance.currentJobAppraisal!.jobID!)-appraisal-\(GUID.generate()).jpg"//"\(GUID.generate()).jpg"
            
            photoNames.append(filename)
            uploadCareURL.append(filename)
            
            let data = image.jpegData(compressionQuality: 0.75)//UIImageJPEGRepresentation(image, Defaults.compression);
            
            let path = OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!, pickup: pickup) + "/" + filename
            
            
            do {
                CustomPhotoAlbum.shared.save(image: image)
                //UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                try data!.write(to: URL(string:path)!, options: Data.WritingOptions.atomicWrite)
                print("Photo Added");
            }
            catch {
                photoNames.remove(filename)
                let index = photoNames.index(of:filename)
                if let objIndex = index,self.uploadCareURL.count > objIndex {
                    uploadCareURL.remove(at: objIndex)
                }
                print("Photo not added");
                let exception = NSException(name:NSExceptionName(rawValue: "addImagesToArray"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
            }
            
            
        }
        
        //upload care
        self.uploadCareWithPhotoNames(images: images)
        //photoDelegate?.updatePhotos(photoNames: photoNames)
        
    }
    func uploadCareWithPhotoNames(images: [UIImage]){
        DispatchQueue.main.async {
            ProgressHud.show()
        }
        if self.photoNames.count > 0,let fileName = self.photoNames.last,let objImage = images.last{
            
            if let imageData = objImage.jpegData(compressionQuality: 0.75){
                let uploadCareRequest = UCFileUploadRequest.init(fileData: imageData, fileName: "\(fileName)", mimeType:"image/jpeg")
                UCClient.default()?.performUCRequest(uploadCareRequest, progress: { (totalBytesSent, totalBytesExpectedToSend) in
                    print(totalBytesSent)
                    print(totalBytesExpectedToSend)
                }, completion: { (response, error) in
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                    }
                    if let _ = error{
                        print("\nError :-\n\(error!.localizedDescription)")
                        
                    }else{
                        print("\nSuccess :-\n\(response ?? "")")
                        if let objResponse = response as? [String:Any],let udid = objResponse["file"]{
                            let url = "\(NSString.uc_path(withUUID: "\(udid)") ?? "")\(fileName.replacingOccurrences(of:"-", with:""))"
                            let index = self.photoNames.index(of:"\(fileName)")
                            if let objIndex = index,self.uploadCareURL.count+1 > objIndex {
                                self.uploadCareURL.remove(at: objIndex)
                                self.uploadCareURL.insert(url, at: objIndex)
                            }
                            DispatchQueue.main.async {
                                self.collView.reloadData()
                                //self.photoDelegate?.updatePhotos(photoNames: self.photoNames)
                                self.photoDelegate?.updatePhotos(photoNames: self.photoNames, uploadCare: self.uploadCareURL)
                            }
                        }
                    }
                })
            }else{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
            }
        }else{
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
        }
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            //            present(ac, animated: true)
            print("Saved error")
            
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            print("Saved!")
            //            present(ac, animated: true)
        }
    }
    /*
    private static func imageUploadCare(endpoint : URL, jobID : Int, path : String, filename : String,isCustomerSignature:Bool = false, completion:@escaping (_ success:Bool)->())  {
        
        
        if let imagedataURL = URL.init(string: path){
            do{
                let data = try Data.init(contentsOf: imagedataURL,options: .mappedIfSafe)
                let uploadCareRequest = UCFileUploadRequest.init(fileData: data, fileName: "\(filename)", mimeType:"image/jpeg")
                UCClient.default()?.performUCRequest(uploadCareRequest, progress: { (totalBytesSent, totalBytesExpectedToSend) in
                    print(totalBytesSent)
                    print(totalBytesExpectedToSend)
                }, completion: { (response, error) in
                    if let _ = error{
                        print("URL:- \(endpoint) \nError :-\n\(error!.localizedDescription)")
                        completion(false)
                    }else{
                        print("URL:- \(endpoint) \nSuccess :-\n\(response ?? "")")
                        if let objResponse = response as? [String:Any],let udid = objResponse["file"]{
                            self.replaceJSONObject(jobid:jobID,fileName: filename,path:path, response: "\(udid)",isCustomerSignature:isCustomerSignature)
                        }
                        completion(true)
                    }
                })
            }catch{
                let exception = NSException(name:NSExceptionName(rawValue: "imageUploadCare"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print("URL:- \(endpoint) \nError :-\n\(error.localizedDescription) \nPath:- \(path)")
                completion(false)
            }
        }else{
            completion(false)
        }
        
    }*/
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func removeImageWithFilename(filename: String) {
        
        photoNames.remove(filename)
        let index = photoNames.index(of:filename)
        if let objIndex = index,self.uploadCareURL.count > objIndex {
            uploadCareURL.remove(at: objIndex)
        }
        
        collView.reloadData()
        photoDelegate?.updatePhotos(photoNames: self.photoNames, uploadCare: self.uploadCareURL)
        //photoDelegate?.updatePhotos(photoNames: photoNames)
    }
    
    
}
class CustomPhotoAlbum: NSObject {
    static let albumName = "G4 Driver"
    static let shared = CustomPhotoAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded()
            completion(true)
        }
        else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    // Unable to create album
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    let enumeration: NSArray = [assetPlaceHolder!]
                    albumChangeRequest!.addAssets(enumeration)
                    
                }, completionHandler: nil)
            }
        }
    }
}
