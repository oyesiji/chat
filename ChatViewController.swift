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
import FirebaseStorage
import FirebaseAuth
class ChatViewController: JSQMessagesViewController{
    var messages = [JSQMessage]()
     let messageRef = FIRDatabase.database().reference().child("messages")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = FIRAuth.auth()?.currentUser
        
        self.senderId = currentUser?.uid;
        self.senderDisplayName = "abbey"
       
        print(messageRef)
        
       observeMessages()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logOut(_ sender: Any) {
        print("Login Anonym")
        do{
            try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVc
        
        
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
         let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId {
           
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black);
        }else{
            
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.blue);
        }
        
        
       
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
                let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                if mediaType == "TEXT" {
                    let text = dict["text"] as! String
                     self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text));
                }else if mediaType == "PHOTO"{
                    let fileUrl = dict["fileUrl"] as! String
                    let url = NSURL(string:fileUrl)
                    let data = NSData(contentsOf: url! as URL)
                    let picture = UIImage(data:data! as Data);
                    let photo = JSQPhotoMediaItem(image:picture);
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo));
                    if self.senderId == senderId{
                         photo?.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        photo?.appliesMediaViewMaskAsOutgoing = false

                    }
                   
                }else if mediaType == "VIDEO"{
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                     let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
                    if self.senderId == senderId{
                        videoItem?.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        videoItem?.appliesMediaViewMaskAsOutgoing = false
                        
                    }
                   
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem));
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
        self.finishSendingMessage();
             }
  
    func sendMedia(picture:UIImage?,video:NSURL?){
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata){
                (metadata,error) in
                if error != nil
                {
                    print(error?.localizedDescription)
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId();
                
                let messageData = ["fileUrl":fileUrl, "senderId":self.senderId, "senderName":self.senderDisplayName, "MediaType" :"PHOTO"]
                newMessage.setValue(messageData)
                
                
                
            }
        }else if let video = video {
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video as URL)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metadata){
                (metadata,error) in
                if error != nil
                {
                    print(error?.localizedDescription)
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId();
                
                let messageData = ["fileUrl":fileUrl, "senderId":self.senderId, "senderName":self.senderDisplayName, "MediaType" :"PHOTO"]
                newMessage.setValue(messageData)
                
                
                
            }

        }
      
       
    
    }
    
}



extension ChatViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("#### it works")
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        //    let photo = JSQPhotoMediaItem(image: picture);
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            sendMedia(picture: picture, video: nil)
        }else if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
           // let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            sendMedia(picture: nil, video:video)
        }
        
        
        
        
       
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData();

    }
    
    
    
}
