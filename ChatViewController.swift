//
//  LogoutViewController.swift
//  GChat
//
//  Created by Jubril Oyesiji on 3/10/17.
//  Copyright © 2017 Jubril Oyesiji. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController{
    var messages = [JSQMessage]()
     let messageRef = FIRDatabase.database().reference().child("messages")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "abbey"
       
        print(messageRef)
       
      //  messageRef.childByAutoId().setValue("first Message")
     //   messageRef.childByAutoId().setValue("second Message")
     //   messageRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
 //
        //    if let dict = snapshot.value as? NSDictionary {
       //         print(dict)
        //    }
           
      //  })
        
       observeMessages()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logOut(_ sender: Any) {
        print("Login Anonym")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVc
        
        
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black);
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
  
    

    
    override func didPressAccessoryButton(_ sender: UIButton!) {
         print("### we are here")
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel){(alert:UIAlertAction) in
            
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default){(alert:UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default){(alert:UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil);
        
        //let imagePicker = UIImagePickerController()
       // imagePicker.delegate = self
       // self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("### did tap \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL);
                let playerViewController = AVPlayerViewController();
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil);
            }
          
            
        }
        
        
        
    }
    
    
    
    func getMediaFrom(type:CFString){
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self;
        mediaPicker.mediaTypes = [type as String];
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    
    func observeMessages(){
        messageRef.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String:AnyObject] {
                let MediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                if let text = dict["text"] as? String {
                     self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text));
                }else {
                    let fileUrl = dict["fileUrl"] as! String
                    let data = NSData(contentsOf: NSURL(string:fileUrl)! as URL)
                    let picture = UIImage(data: data! as Data)
                    let photo = JSQPhotoMediaItem(image:picture)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo));

                    
                }
                
                
               
               
                 self.collectionView.reloadData();
            }
            
            
           
  
            
        })
    }
    
     override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        let newMessage = messageRef.childByAutoId()
      //  newMessage.setValue(<#T##value: Any?##Any?#>)
        let messageData = ["text":text, "senderId":senderId, "senderName":senderDisplayName, "MediaType" :"TEXT"]
        newMessage.setValue(messageData)
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text));
             }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension ChatViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("#### it works")
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let photo = JSQPhotoMediaItem(image: picture);
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        }else if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
            let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            
        }
        
        
        
        
       
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData();

    }
    
    
    
}
