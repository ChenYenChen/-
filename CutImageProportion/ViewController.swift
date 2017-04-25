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
        let cut = CutImage()
        cut.cutDelegate = self
        //cut.originalImage = UIImage(named: "one") // 寬的圖
        cut.originalImage = UIImage(named: "two") // 長的圖
        self.present(cut, animated: true, completion: nil)
    }
    @IBOutlet weak var endCutImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: CutImageDelegate {
    func didGetImage(_ image: UIImage) {
        self.endCutImage.image = image
    }
}

