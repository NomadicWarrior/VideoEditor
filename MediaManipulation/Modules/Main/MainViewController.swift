//
//  MainViewController.swift
//  MediaManipulation
//
//  Created by Nurlan Akylbekov  on 27.08.2022.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos

final class MainViewController: BaseViewController {
  
  private var rootView = MainView()
  
  private var videoController: AVPlayerViewController?
  
  private var player = AVQueuePlayer()
  
  private var videoURL: URL? {
    didSet {
      guard let videoURL = videoURL else {
        return
      }
      addVideoItem(videoURL)
    }
  }
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoController?.player?.currentItem)
  }
  
  private func bindView() {
    
    rootView.didTapAdd = { [weak self] in
      self?.openPicker()
    }
    
    rootView.didTapCut = { [weak self] in
      guard let url = self?.videoURL else { return }
      self?.trimVideo(url: url)
    }
    
    rootView.didTapDivide = { [weak self] in
      guard let url = self?.videoURL else { return }
      self?.divide(url: url)
    }
    
    rootView.didTapPlay = { [weak self] in
      guard let player = self?.videoController?.player else { return }
      
      if player.currentItem == nil {
        
        guard let videoURL = self?.videoURL else {
          return
        }
        self?.addVideoItem(videoURL)
      }
      
      if player.timeControlStatus == .playing {
        player.pause()
      } else {
        player.play()
        self?.rootView.hideControls()
      }
      
      self?.rootView.isPlaying = player.timeControlStatus == .waitingToPlayAtSpecifiedRate ? true : false
    }
  }
  
  @objc func playerDidFinishPlaying(note: NSNotification){
    rootView.isPlaying = false
    rootView.isControlHidden = false
  }
  
  private func trimVideo(url: URL) {
    
    let alert = UIAlertController(title: "Edit your video",
                                  message: "Edited video will be saved in camera roll", preferredStyle: .alert)
    
    alert.addTextField { (from) in
      from.placeholder = "From..."
      from.textColor = .lightGray
      from.keyboardType = .numberPad
    }
    alert.addTextField { (to) in
      to.placeholder = "To..."
      to.textColor = .lightGray
      to.keyboardType = .numberPad
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
      
      let fromField = alert?.textFields![0]
      let toField = alert?.textFields![1]
      
      guard let startConvert = Double((fromField?.text)!), let endConvert = Double((toField?.text)!) else {
        return
      }
      
      let startTime = CMTimeMakeWithSeconds(startConvert, preferredTimescale: 600)
      let endTime = CMTimeMakeWithSeconds(endConvert, preferredTimescale: 600)
      
      let asset = AVAsset(url: url)
      
      let composition = AVVideoComposition(propertiesOf: asset)
      
      self.export(asset, to: url, startTime: startTime, endTime: endTime, composition: composition) { [weak self] urlAddress in
        
        guard let urlAddress = urlAddress else {
          return
        }

        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlAddress.path) {
          
          UISaveVideoAtPathToSavedPhotosAlbum(urlAddress.path,
                                              self,
                                              #selector(self?.video(_:didFinishSavingWithError:contextInfo:)),
                                              nil)
        }
      }
      
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  private func addVideoView() {
    videoController = AVPlayerViewController()
    
    guard let videoController = videoController, let overlayView = videoController.contentOverlayView else {
      return
    }
    
    videoController.showsPlaybackControls = false
    videoController.player = player
    
    addChild(videoController)
    rootView.addVideoView(videoView: videoController.view,
                          overlayView: overlayView)
    videoController.didMove(toParent: self)
  }
  
  private func addVideoItem(_ url: URL) {
    let item = AVPlayerItem(url: url)
    player.removeAllItems()
    player.insert(item, after: nil)
  }
  
  private func export(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition, completion: @escaping (URL?) -> Void) {
    
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
          self.showError(with: error)
        } else {
          completion(outputMovieURL)
        }
      }
    })
  }
  
  private func divide(url: URL) {
    let viewModel = DividedViewModel(url: url)
    let vc = DividedViewController(viewModel: viewModel)
    vc.modalPresentationStyle = .overFullScreen
    self.present(vc, animated: true, completion: nil)
  }
}

// MARK: - UIImagePickerController

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private func openPicker() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .savedPhotosAlbum
    picker.mediaTypes = [kUTTypeMovie as String]
    picker.allowsEditing = false
    
    present(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
    
    if let vc = videoController {
      rootView.removeVideoView(videoView: vc.view)
      vc.didMove(toParent: nil)
      vc.removeFromParent()
    }
    videoURL = nil
    videoController = nil
    videoURL = url
    addVideoView()
    
    dismiss(animated: true, completion: nil)
  }
  
  @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
    
    guard let error = error else {
      self.videoURL = nil
      self.videoURL = URL(string: "file://\(videoPath)")!
      return
    }
    showError(with: error)
  }
}
