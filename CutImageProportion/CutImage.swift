//
//  CutImage.swift
//  ForNewProject
//
//  Created by 陳彥辰 on 2017/4/20.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit

protocol CutImageDelegate {
    func didGetImage(_ image: UIImage)
}

class CutImage: UIViewController {

    fileprivate let width: CGFloat = UIScreen.main.bounds.width
    fileprivate let height: CGFloat = UIScreen.main.bounds.height
    private var toolBar: UIView!
    
    fileprivate var scrollView: UIScrollView!
    fileprivate var imageView: UIImageView!
    private var centerView: UIView!
    private var finalButton: UIButton!
    private var canelButton: UIButton!
    private var isFirst: Bool = true
    fileprivate var newHeight: CGFloat = 0
    var cutDelegate: CutImageDelegate?
    var originalImage: UIImage?
    
    private func buildScroll() {
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.backgroundColor = UIColor.clear
        self.imageView = UIImageView()
        self.scrollView.addSubview(self.imageView)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }
    
    private func buildCover() {
        let cutHeight: CGFloat = self.width / 16 * 9
        let coverHeight: CGFloat = (self.height - cutHeight) / 2
        let topView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: coverHeight))
        topView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4)
        topView.isUserInteractionEnabled = false
        self.view.addSubview(topView)
        
        centerView = UIView(frame: CGRect(x: 0, y: coverHeight, width: width, height: cutHeight))
        centerView.layer.borderColor = UIColor.white.cgColor
        centerView.layer.borderWidth = 1
        centerView.isUserInteractionEnabled = false
        self.view.addSubview(centerView)
        
        let bottomView: UIView = UIView(frame: CGRect(x: 0, y: coverHeight + cutHeight, width: width, height: coverHeight))
        bottomView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4)
        bottomView.isUserInteractionEnabled = false
        self.view.addSubview(bottomView)
    }
    
    private func buildToolBar() {
        self.toolBar = UIView(frame: CGRect(x: 0, y: self.height - 40, width: width, height: 40))
        self.toolBar.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.7)
        
        
        self.finalButton = UIButton(frame: CGRect(x: width / 2, y: 0, width: width / 2, height: 40))
        self.canelButton = UIButton(frame: CGRect(x: 0, y: 0, width: width / 2, height: 40))
        
        self.finalButton.setTitle("確定", for: .normal)
        self.canelButton.setTitle("取消", for: .normal)
        
        self.canelButton.addTarget(self, action: #selector(backView), for: .touchUpInside)
        self.finalButton.addTarget(self, action: #selector(cutImage), for: .touchUpInside)
        
        self.toolBar.addSubview(self.finalButton)
        self.toolBar.addSubview(self.canelButton)
        
        self.view.addSubview(self.toolBar)
    }
    
    private func buildImage() {
        guard let getImage = self.originalImage else {
            return
        }
        
        let scale: CGFloat = self.width / getImage.size.width
        self.newHeight = getImage.size.height * scale
        
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.width, height: newHeight)
        
        self.imageView.image = self.originalImage
        self.scrollView.contentSize = CGSize(width: self.width, height: newHeight)
        
        let coverHeight: CGFloat = (self.height - newHeight) / 2
        self.scrollView.contentInset = UIEdgeInsets(top: coverHeight, left: 0, bottom: coverHeight, right: 0)
    }
    
    @objc private func cutImage() {
        let newImage = self.croppedImage(image: self.imageView.image!, frame: cutFrame())
        self.cutDelegate?.didGetImage(newImage)
        self.backView()
    }
    
    private func croppedImage(image: UIImage, frame: CGRect) -> UIImage {
        let sourceImage: CGImage = image.cgImage!
        let newImage: CGImage = sourceImage.cropping(to: frame)!
        return UIImage(cgImage: newImage)
    }
    
    private func cutFrame() -> CGRect {
        let imageSize = self.imageView.image!.size
        let contentSize = self.scrollView.contentSize
        let cropBoxFrame = self.centerView.frame
        let contentOffset = self.scrollView.contentOffset
        let edgeInsets = self.scrollView.contentInset
        
        var frame = CGRect.zero
        frame.origin.x = (contentOffset.x + edgeInsets.left) * (imageSize.width / contentSize.width)
        frame.origin.y = (contentOffset.y + edgeInsets.top) * (imageSize.height / contentSize.height)
        frame.size.width = cropBoxFrame.size.width * (imageSize.width / contentSize.width)
        frame.size.height = cropBoxFrame.size.height * (imageSize.height / contentSize.height)
        
        return frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let na = self.navigationController {
            na.isNavigationBarHidden = true
        }
        
        self.buildScroll()
        self.buildCover()
        self.buildToolBar()
        self.buildImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc private func backView() {
        if let na = self.navigationController {
            na.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let na = self.navigationController {
            na.isNavigationBarHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension CutImage: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        let cutHeight: CGFloat = self.width / 16 * 9
        let coverHeight: CGFloat = (self.height - cutHeight) / 2
        var endHeight: CGFloat = 0
        if scrollView.contentSize.height > coverHeight {
            endHeight = coverHeight
        } else {
            endHeight = (self.height - newHeight) / 2
        }
        
        self.scrollView.contentInset = UIEdgeInsets(top: endHeight, left: 0, bottom: endHeight, right: 0)
    }
}