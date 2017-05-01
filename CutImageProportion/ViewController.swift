//
//  ViewController.swift
//  CutImageProportion
//
//  Created by 陳彥辰 on 2017/4/25.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func startCut(_ sender: Any) {
        // 從相簿取得圖片
        self.present(self.takePicture, animated: true, completion: nil)
    }
    @IBOutlet weak var endCutImage: UIImageView!
    
    var sourceType : UIImagePickerControllerSourceType!
    let takePicture : UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.takePicture.delegate = self
        self.takePicture.sourceType = sourceType
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: CutImageDelegate {
    func didGetImage(_ cut: CutImage, image: UIImage) {
        self.endCutImage.image = image
        cut.dismiss(animated: true, completion: nil)
    }
}
//MARK: - 取得圖片
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let infos: NSDictionary = info as NSDictionary
        
        //取得圖片 - 原圖
        let originalImage: UIImage = infos.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        let cut = CutImage()
        // 裁切比例
        cut.proportion = 9 / 16
        cut.cutDelegate = self
        // 圖片
        cut.originalImage = originalImage
        picker.pushViewController(cut, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

