# CutImageWithProportion
Swift 3 自訂圖片裁切比例

//取得圖片 - 從相簿取得圖片

let originalImage: UIImage = infos.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage

let cut = CutImage()

cut.proportion = 9 / 16 // 裁切比例

cut.cutDelegate = self

cut.originalImage = originalImage  // 圖片

picker.pushViewController(cut, animated: true)

