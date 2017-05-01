//
//  CutImage.swift
//  ForNewProject
//
//  Created by 陳彥辰 on 2017/4/20.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit

protocol CutImageDelegate {
    func didGetImage(_ cut: CutImage, image: UIImage)
}

class CutImage: UIViewController {

    fileprivate let width: CGFloat = UIScreen.main.bounds.width
    fileprivate let height: CGFloat = UIScreen.main.bounds.height
    private var toolBar: UIView!
    
    fileprivate var scrollView: UIScrollView!
    fileprivate var imageView: UIImageView!
    fileprivate var centerView: UIView!
    private var finalButton: UIButton!
    private var canelButton: UIButton!
    var proportion: CGFloat = (9 / 16)
    var cutDelegate: CutImageDelegate?
    var originalImage: UIImage?
    
    // 建立ScrollView
    private func buildScroll() {
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
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
    // 建立遮罩
    private func buildCover() {
        let cutHeight: CGFloat = self.width * self.proportion
        let coverHeight: CGFloat = (self.height - cutHeight) / 2
        // 上遮罩
        let topView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: coverHeight))
        topView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4)
        topView.isUserInteractionEnabled = false
        self.view.addSubview(topView)
        // 中間裁切的框框
        centerView = UIView(frame: CGRect(x: 0, y: coverHeight, width: width, height: cutHeight))
        centerView.layer.borderColor = UIColor.white.cgColor
        centerView.layer.borderWidth = 1
        centerView.isUserInteractionEnabled = false
        self.view.addSubview(centerView)
        // 下遮罩
        let bottomView: UIView = UIView(frame: CGRect(x: 0, y: coverHeight + cutHeight, width: width, height: coverHeight))
        bottomView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4)
        bottomView.isUserInteractionEnabled = false
        self.view.addSubview(bottomView)
        
    }
    // 建立按鈕
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
    // 建立圖片
    private func buildImage() {
        guard let getImage = self.originalImage else {
            return
        }
        
        let scale: CGFloat = self.width / getImage.size.width
        let newHeight = getImage.size.height * scale
        
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.width, height: newHeight)
        
        self.imageView.image = getImage
        self.scrollView.contentSize = CGSize(width: self.width, height: newHeight)
        
        self.imageOffect(self.scrollView)
        
        if newHeight > self.centerView.bounds.height {
            let pointY: CGFloat = ((newHeight - self.centerView.bounds.height) / 2) - self.scrollView.contentInset.top
            self.scrollView.contentOffset = CGPoint(x: 0, y: pointY)
        }
    }
    // 圖片位置
    fileprivate func imageOffect(_ scrollView: UIScrollView) {
        
        if scrollView.contentSize.height > self.centerView.bounds.height {
            // 圖片高度大於遮罩
            let coverHeight: CGFloat = (self.height - self.centerView.bounds.height) / 2
            self.scrollView.contentInset = UIEdgeInsets(top: coverHeight, left: 0, bottom: coverHeight, right: 0)
        } else {
            // 圖片高度小於遮罩
            let coverHeight: CGFloat = (self.height - scrollView.contentSize.height) / 2
            self.scrollView.contentInset = UIEdgeInsets(top: coverHeight, left: 0, bottom: coverHeight, right: 0)
        }
    }
    
    // 圖片縮放
    private func originImage(_ image: UIImage, scaleSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaleImage
    }
    // 執行圖片裁切
    @objc private func cutImage() {
        guard let getimage = self.originalImage else {
            return
        }
        let newImage = self.croppedImage(image: getimage, frame: cutFrame())
        self.cutDelegate?.didGetImage(self, image: newImage)
    }
    // 裁減圖片
    private func croppedImage(image: UIImage, frame: CGRect) -> UIImage {
        let sourceImage: CGImage = image.cgImage!
        let newImage: CGImage = sourceImage.cropping(to: frame)!
        let endImage: UIImage = UIImage(cgImage: newImage)
        return endImage
    }
    // 裁切範圍
    private func cutFrame() -> CGRect {
        
        let imageSize = self.imageView.image!.size
        let contentSize = self.scrollView.contentSize
        let cropBoxFrame = self.centerView.bounds
        let contentOffset = self.scrollView.contentOffset
        let edgeInsets = self.scrollView.contentInset
        
        var frame = CGRect.zero
        frame.origin.x = (contentOffset.x + edgeInsets.left) * (imageSize.width / contentSize.width)
        frame.origin.y = (contentOffset.y + edgeInsets.top) * (imageSize.height / contentSize.height)
        frame.size.width = cropBoxFrame.width * (imageSize.width / contentSize.width)
        frame.size.height = cropBoxFrame.height * (imageSize.height / contentSize.height)
        
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
    // 隱藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return true
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
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.imageOffect(scrollView)
    }
}
