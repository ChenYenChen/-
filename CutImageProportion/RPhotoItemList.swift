//
//  RPhotoItemList.swift
//  CutImageProportion
//  相簿相清單列表
//  Created by Ray on 2017/4/28.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit
import Photos

// 相簿列表
struct RImageAlbumItem {
    // 相簿名稱
    var title: String?
    // 相簿內資源
    var fetchResult: PHFetchResult<PHAsset>
}

class RPhotoItemList: UINavigationController {

    //相簿列表集合
    fileprivate var items:[RImageAlbumItem] = []
    private var itemTableView: UITableView!
    
    // 相簿權限判斷
    private func photoAuthorization() {
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else {
                return
            }
            
            //列出所有系統相簿
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions)
            self.getItems(item: smartAlbums)
            
            //列出所有的相簿
            let userPhotos = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.getItems(item: userPhotos
                as! PHFetchResult<PHAssetCollection>)
            
            //相簿按包含的照片數量排序（降序）
            self.items.sort { (item1, item2) -> Bool in
                return item1.fetchResult.count > item2.fetchResult.count
            }
            
            //非同步加載數據,需要在主線程調用reloadData() 方法
            DispatchQueue.main.async{
                self.itemTableView.reloadData()
                
                //                //首次进来后直接进入第一个相册图片展示页面（相机胶卷）
                //                if let imageCollectionVC = self.storyboard?
                //                    .instantiateViewController(withIdentifier: "hgImageCollectionVC")
                //                    as? HGImageCollectionViewController{
                //                    imageCollectionVC.title = self.items.first?.title
                //                    imageCollectionVC.assetsFetchResults = self.items.first?.fetchResult
                //                    imageCollectionVC.completeHandler = self.completeHandler
                //                    imageCollectionVC.maxSelected = self.maxSelected
                //                    self.navigationController?.pushViewController(imageCollectionVC,
                //                                                                  animated: false)
                //                }
            }
        }
    }
    
    // 轉化取得的相簿
    private func getItems(item: PHFetchResult<PHAssetCollection>){
        for i in 0..<item.count {
            //取出相簿內的照片
            let itemOptions = PHFetchOptions()
            itemOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
            itemOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
            let c = item[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: itemOptions)
            //沒有照片不顯示
            if assetsFetchResult.count > 0 {
                let title = titleOfAlbumForChinse(title: c.localizedTitle)
                self.items.append(RImageAlbumItem(title: title, fetchResult: assetsFetchResult))
            }
        }
    }
    
    //系统返回的相簿為英文，轉換為中文
    private func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢動作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "個人收藏"
        } else if title == "Recently Deleted" {
            return "最近刪除"
        } else if title == "Videos" {
            return "視頻"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "營幕快照"
        } else if title == "Camera Roll" {
            return "相機"
        }
        return title
    }
    
    private func buildTable() {
        let rect = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)
        self.itemTableView = UITableView(frame: rect)
        self.itemTableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemsCell")
        self.itemTableView.dataSource = self
        self.itemTableView.delegate = self
        self.itemTableView.separatorStyle = .none
        self.view.addSubview(self.itemTableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buildTable()
        self.photoAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension RPhotoItemList: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsCell", for: indexPath)
        let count: String = " (\(self.items[indexPath.row].fetchResult.count))"
        cell.textLabel?.text = self.items[indexPath.row].title! + count
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension RPhotoItemList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}
