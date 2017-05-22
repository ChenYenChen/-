# 自訂圖片裁切比例
Swift 3 自訂圖片裁切比例

- 從相簿取得圖片後
```
//取得圖片 - 從相簿取得圖片
![img](https://github.com/ChenYenChen/CutImageWithProportion/blob/master/照片裁切GIF.gif)
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
}
```
- 取得裁切結束後的照片
```
extension ViewController: CutImageDelegate {
    func didGetImage(_ cut: CutImage, image: UIImage) {
        self.endCutImage.image = image
        cut.dismiss(animated: true, completion: nil)
    }
}
```
