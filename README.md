# CutImageWithProportion
Swift 3 自訂圖片裁切比例

- 從相簿取得圖片後
```
//取得圖片 - 從相簿取得圖片
let originalImage: UIImage = infos.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
let cut = CutImage()
cut.proportion = 9 / 16 // 裁切比例
cut.cutDelegate = self
cut.originalImage = originalImage  // 圖片
picker.pushViewController(cut, animated: true)
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
