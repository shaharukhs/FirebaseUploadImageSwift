//
//  PostServiceFireBase.swift
//  fireBaseUploadImage
//
//  Created by Ascra on 28/10/17.
//  Copyright © 2017 Ascracom.ascratech. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage


struct PostServiceFireBase {
	static func create(for image: UIImage, completion: @escaping (String?) -> ()) {
		let currentDateTime = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMddHH:mm"
		let currentDateTimeString = formatter.string(from: currentDateTime)
		
		let filePath = "YourPath\(currentDateTimeString)" // change path as per your requirement
		
		let imageRef = Storage.storage().reference().child(filePath)
		StorageServiceFireBase.uploadImage(image, at: imageRef) { (downloadURL) in
			guard let downloadURL = downloadURL else {
				print("Download url not found or error to upload")
				return completion(nil)
			}
			
			completion(downloadURL.absoluteString)
		}
	}
	
}


