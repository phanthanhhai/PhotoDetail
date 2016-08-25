//
//  ViewController.swift
//  PhotoDetail
//
//  Created by haipt on 8/24/16.
//  Copyright © 2016 framgia. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func choseImage() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let imgUrl = info["UIImagePickerControllerReferenceURL"] {
            self.getPHAssetByUrl(imgUrl as! NSURL)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    func getPHAssetByUrl(url: NSURL) {
        let allPhotos =  PHAsset.fetchAssetsWithALAssetURLs([url], options: nil)
        if allPhotos.count > 0 {
            let thisImageAsset : PHAsset = allPhotos[0] as! PHAsset
            let RequestOptions = PHContentEditingInputRequestOptions()
            RequestOptions.networkAccessAllowed = true //download asset metadata from iCloud if needed
            
            thisImageAsset.requestContentEditingInputWithOptions(RequestOptions) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                let fullImage = CIImage(contentsOfURL: contentEditingInput!.fullSizeImageURL!)
                print(fullImage!.properties)
                self.detectPhoto(fullImage!.properties)
            }
        }
    }
    
    func detectPhoto(infor: [String: AnyObject]) {
        if let tiff = infor["{TIFF}"] as? NSDictionary {
            if let make = tiff.objectForKey("Make") as? String {
                if make.lowercaseString == "apple" {
                    showAlertView("Photo camera roll")
                } else {
                    showAlertView("Photo other App")
                }
            } else {
                if let software = tiff.objectForKey("Software") as? String {
                    showAlertView("Photo by \(software)")
                } else {
                    showAlertView("Photo other App")
                }
            }
        } else {
            showAlertView("Photo other Source")
        }
    }
    
    func  showAlertView(msg: String) {
        let alertController = UIAlertController(title: "Detected", message: msg, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        })
        alertController.addAction(ok)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

