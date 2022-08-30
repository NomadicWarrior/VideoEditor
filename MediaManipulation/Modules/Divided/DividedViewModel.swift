//
//  DividedViewModel.swift
//  MediaManipulation
//
//  Created by Nurlan Akylbekov  on 29.08.2022.
//

import Foundation
import AVKit
import Photos
import MobileCoreServices

final class DividedViewModel {
  
  var url: URL
  
  var showError: ((Error) -> Void)?
  
  init(url: URL) {
    self.url = url
  }
  
  
   func export(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition, completion: @escaping (URL?) -> Void) {
    
    let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
    
    do {
      try FileManager.default.removeItem(at: outputMovieURL)
    } catch {
      print("Could not remove file \(error.localizedDescription)")
    }
    
    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
    
    exporter?.videoComposition = composition
    exporter?.outputURL = outputMovieURL
    exporter?.outputFileType = .mp4
    exporter?.timeRange = timeRange
    
    exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
      DispatchQueue.main.async {
        if let error = exporter?.error {
          self.showError?(error)
        } else {
          completion(outputMovieURL)
        }
      }
    })
  }
  
}
