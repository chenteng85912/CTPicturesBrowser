# CTPicturesBrowser


 展示网络图片，传入参数
 
 1、图片数组(图片本身或者图片下载地址)imageArray

 2、当前图片位置currentNum
 
     //控制器
     [CTImagePreviewViewController showPictureWithUrlOrImages:@[image] withCurrentPageNum:0]

     //视图
     [CTPictureBrowser showPictureWithUrlOrImages:@[image] withCurrentPageNum:0]
