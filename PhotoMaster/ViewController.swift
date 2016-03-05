//
//  ViewController.swift
//  PhotoMaster
//
//  Created by Aoi Sakaue on 2016/02/12.
//  Copyright © 2016年 Aoi Sakaue. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var photoImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func precentPickerController(sourceType: UIImagePickerControllerSourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let picker = UIImagePickerController()
            
            picker.sourceType = sourceType
            
            picker.delegate = self
            
            self.presentViewController(picker, animated: true, completion: nil)
        
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        photoImageView.image = image
    }
    @IBAction func selectButtonTapped(sender: UIButton) {
        
        let alertController = UIAlertController(title: "画像の取得先を選択", message: nil, preferredStyle: .ActionSheet)
        
        let firstAction = UIAlertAction(title: "カメラ", style: .Default) {
            action in
            self.precentPickerController(.Camera)
        }
        let secondAction = UIAlertAction(title: "アルバム", style: .Default) {
            action in
            self.precentPickerController(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
}
    }
//元の画像にテキストを合成するメソッド
func drawText(image: UIImage) -> UIImage {
    
    let text = "LifeisTech!\nXmasCamp2015💖"
    
    UIGraphicsBeginImageContext(image.size)
    
    image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
    
    let textRect = CGRectMake(5, 5, image.size.width - 5, image.size.height - 5)
    
    let textFontAttributes = [
        NSFontAttributeName: UIFont.boldSystemFontOfSize(120),
        NSForegroundColorAttributeName: UIColor.redColor(),
        NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle()
    ]
    
    text.drawInRect(textRect, withAttributes: textFontAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return newImage
}

//元の画像にマスク画像を合成するメソッド
func drawMaskImage(image: UIImage) -> UIImage {
    
    UIGraphicsBeginImageContext(image.size)
    
    image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
    
    let maskImage = UIImage(named: "santa")
    
    let offset: CGFloat = 50.0
    let maskRect = CGRectMake(
        image.size.width - maskImage!.size.width - offset,
        image.size.height - maskImage!.size.width - offset,
        maskImage!.size.width,
        maskImage!.size.height
    )
    
    maskImage!.drawInRect(maskRect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return newImage
}

//任意のメッセージとOKボタンを持つアラートのメソッド
    func simpleAlert(titleString: String) {
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
    
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
//！！！presentViewControllerがエラーとして提示されてしまう！！！
        presentViewController(alertController, animated: true, completion: nil)

}


//「合成」ボタンを押した時に呼ばれるメソッド
//！！１@IBActionとphotoImageViewがエラー！！！
    func processButtonTapped(sender: UIButton) {
    
    guard let selectedPhoto = photoImageView.image else {
        
        simpleAlert("画像がありません")
        return
    }
        let alertController = UIAlertController(title: "合成するパーツを選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "テキスト", style: .Default){
            action in
            
//！！！selfがエラー！！！
            self.photoImageView.image = self.drawText(selectedPhoto)
        }
        
        let secoundAction = UIAlertAction(title: "サンタマーク", style: .Default) {
            action in
//selectedPhotoに画像を合成して画面に描き出す
//！！！selfがエラー！！！
            self.photoImageView.image = self.drawMaskImage(selectedPhoto)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secoundAction)
        alertController.addAction(cancelAction)
//！！１presentViewControllerがエラー！！！
        presentViewController(alertController, animated: true, completion: nil)
        
}
//SNSに投稿するメソッド(FacebookかTwitterのソースタイプが引き数）
func postToSNS(serviceType: String) {
    let myComposeView = SLComposeViewController(forServiceType: serviceType)
    
    myComposeView.setInitialText("photoMasterからの投稿✨")
    
    myComposeView.addImage(photoImageView.image)
    
    self.presentViewController(myComposeView, animated: true, completion: nil)
}

//「アップロード」ボタンを押した時に呼ばれるメソッド
func uploadButtonTapped(sender: UIButton) {
    
    guard let selectedPhoto = photoImageView.image else {
        simpleAlert("画像がありません")
        return
    }
    
    let alertController = UIAlertController(title: "アップロード先を選択", message: nil, preferredStyle: .ActionSheet)
    
    let firstAction = UIAlertAction(title: "Facebookに投稿", style: .Default) {
            action in
            self.posToSNS(SLServiceTypeFacebook)
    }
    let secondAction = UIAlertAction(title: "Twitterに投稿", style: .Default) {
            action in
            self.posToSNS(SLServiceTypeTwitter)
    }
    let thirdAction = UIAlertAction(title: "カメラロールに保存", style: .Default) {
        action in
         UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, nil, nil)
        self.simpleAlert("アルバムに保存されました。")
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
    
    alertController.addAction(firstAction)
    alertController.addAction(secondAction)
    alertController.addAction(thirdAction)
    alertController.addAction(cancelAction)
    
    presentViewController(alertController, animated: ture, completion: nil)
    
        
    }



//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }




