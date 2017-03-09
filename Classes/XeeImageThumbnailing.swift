//
//  XeeImageThumbnailing.swift
//  Xee
//
//  Created by C.W. Betts on 3/9/17.
//
//

import Cocoa

extension XeeImage {
	@objc(makeRGBThumbnailOfSize:)
	func makeRGBThumbnail(of size: Int) -> CGImage? {
		var thumbnail: CGImage? = nil
		
		if let cgimage = self.createCGImage() {
			let cgwidth = cgimage.width
			let cgheight = cgimage.height
			var thumbwidth = 0, thumbheight = 0;
			
			if cgwidth > cgheight {
				thumbwidth = size
				thumbheight = (size * cgheight) / cgwidth
			} else {
				thumbwidth = (size * cgwidth) / cgheight
				thumbheight = size
			}
			
			if let thumbdata = CFDataCreateMutable(kCFAllocatorDefault, thumbwidth * thumbheight * 4),
				let context = CGContext(data: CFDataGetMutableBytePtr(thumbdata),
				                        width: thumbwidth, height: thumbheight,bitsPerComponent: 8,
				                        bytesPerRow: thumbwidth * 4, space: cgimage.colorSpace!,
				                        bitmapInfo: 0) {
				context.interpolationQuality = .high;
				context.draw(cgimage, in: CGRect(x: 0, y: 0, width: thumbwidth, height: thumbheight))
				thumbnail = context.makeImage()
			}
		}
		return thumbnail
	}
	
	@objc(makeJPEGThumbnailOfSize:maxBytes:)
	func makeJPEGThumbnail(of size: Int, maxBytes: Int) -> Data? {
		guard let thumbnail = self.makeRGBThumbnail(of: size) else {
			return nil
		}
		
		var thumbdata: NSMutableData? = nil
		var quality = 60
		repeat {
			if let data=CFDataCreateMutable(kCFAllocatorDefault,0),
				let dest=CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil) {
				let options: [String:Any] = [kCGImageDestinationLossyCompressionQuality as String: Double(quality)/100.0]
				
				CGImageDestinationAddImage(dest,thumbnail,options as NSDictionary)
				
				if CGImageDestinationFinalize(dest) {
					if CFDataGetLength(data) < maxBytes {
						thumbdata = data
					}
				}
			}
			quality-=10
			
		} while thumbdata != nil && quality > 0
		
		if let thumbdata = thumbdata {
			return thumbdata as NSData as Data
		}
		
		return nil
	}
}
