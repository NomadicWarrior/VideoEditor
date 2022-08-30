//
//  DividedViewController.swift
//  MediaManipulation
//
//  Created by Nurlan Akylbekov  on 29.08.2022.
//

import UIKit
import AVKit

final class DividedViewController: BaseViewController {
  
  private var rootView = DividedView()
  
  private var viewModel: DividedViewModel
  
  init(viewModel: DividedViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("Free")
  }
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindViewModel()
    
    rootView.dismiss = { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }
    
    rootView.swipe = {
      
    }
  }
  
  private func bindViewModel() {
    viewModel.showError = { [weak self] error in
      self?.showError(with: error)
    }

    let asset = AVAsset(url: viewModel.url)
    
    let length = Float(asset.duration.value) / Float(asset.duration.timescale)
    let start = CMTimeMakeWithSeconds(0.01, preferredTimescale: 600)
    let halfTime = CMTimeMakeWithSeconds(Double(length)/2, preferredTimescale: 600)
    let composition = AVVideoComposition(propertiesOf: asset)
    let endTime = CMTimeMakeWithSeconds(Double(length), preferredTimescale: 600)
    
    viewModel.export(asset, to: viewModel.url, startTime: start, endTime: halfTime, composition: composition) { [weak self] url in
      
      guard let url = url else {
        return
      }
      
      if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
        
        UISaveVideoAtPathToSavedPhotosAlbum(url.path,
                                            self,
                                            #selector(self?.video(_:didFinishSavingWithError:contextInfo:)),
                                            nil)
      }
    }
    
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.viewModel.export(asset, to: self.viewModel.url, startTime: halfTime, endTime: endTime, composition: composition) { [weak self] url in
        
        guard let url = url else {
          return
        }
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
          
          UISaveVideoAtPathToSavedPhotosAlbum(url.path,
                                              self,
                                              #selector(self?.video(_:didFinishSavingWithError:contextInfo:)),
                                              nil)
        }
      }
    }
  }
  
  @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
    
    let item = AVPlayerItem(url: URL(string: "file://\(videoPath)")!)
    
    let player = AVPlayer(playerItem: item)
    let playerController = AVPlayerViewController()
    playerController.player = player
    addChild(playerController)
    
    rootView.addVideoViews(playerController.view)
    playerController.didMove(toParent: self)
    
  }
}
