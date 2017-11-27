//
//  ViewController.swift
//  fireBaseUploadImage
//
//  Created by Ascra on 28/10/17.
//  Copyright © 2017 Ascracom.ascratech. All rights reserved.
//

import UIKit
import FirebaseStorage
import Toaster
import Photos
import AudioToolbox

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
	@IBOutlet weak var userPhotoImageView: UIImageView!
	@IBOutlet weak var downloadImageStringLabel: UILabel!
	let imagePicker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		imagePicker.delegate = self
		
	}
	
	//MARK: - Button actions
	@IBAction func uploadImageButtonClick(_ sender: Any) {
		let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
		switch photoAuthorizationStatus {
		case .authorized:
			print("Access is granted by user")
			self.askForChooeseImageType()
			
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization({
				(newStatus) in
				print("status is \(newStatus)")
				if newStatus ==  PHAuthorizationStatus.authorized {
					/* do stuff here */
					print("success")
					self.askForChooeseImageType()
				}
			})
			print("It is not determined until now")
			
		case .restricted:
			print("User do not have access to photo album.")
			
		case .denied:
			print("User has denied the permission.")
		}
	}
	
	func askForChooeseImageType() {
		let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
			self.openCamera()
		}))
		
		alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
			self.openGallary()
		}))
		
		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func openCamera()
	{
		if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
		{
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			self.present(imagePicker, animated: true, completion: nil)
		}
		else
		{
			let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func openGallary()
	{
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		self.present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func downloadImageButtonClick(_ sender: Any) {
		self.showToastMessage(message: "Comming soon!")
	}
	
	@IBAction func copyToClipboardButtonClick(_ sender: Any) {
		if self.downloadImageStringLabel.text != nil {
			UIPasteboard.general.string = self.downloadImageStringLabel.text
			
			self.showToastMessage(message: "Link copy to clipboard")
		}
	}
	
	//MARK: - imagePickerView delegate
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
			self.userPhotoImageView.image = pickedImage
			//			PostServiceFireBase.create(for: pickedImage)
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHH:mm"
            let currentDateTimeString = formatter.string(from: currentDateTime)
            
            let filePath = "YourPath\(currentDateTimeString)" // change path as per your requirement
            PostServiceFireBase.create(for: pickedImage, path: filePath) { (downloadURL) in
				guard let downloadURL = downloadURL else {
					print("Download url not found")
					Toast(text: "Failed to upload image").show()
					return
				}
				
				let urlString = downloadURL
				print("image url for download image :: \(urlString)")
				self.downloadImageStringLabel.text = urlString
				self.showToastMessage(message: "Image uploaded successful")
			}
		}
		dismiss(animated: true, completion: nil)
	}
	
	//MARK: - Toast message
	func showToastMessage(message: String) {
		if let currentToast = ToastCenter.default.currentToast {
			currentToast.cancel()
		}
		Toast(text: message).show()
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) //vibrate on toast
	}

}

