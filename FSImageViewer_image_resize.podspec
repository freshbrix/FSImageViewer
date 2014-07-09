#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "FSImageViewer_image_resize"
  s.version          = "1.1"
  s.summary          = "Library added additonal functionality on FSImagViewer"
  s.description      = "Image resizing functionality is added on image download success of FSImageViewer"
  s.homepage     = "https://github.com/x2on/FSImageViewer"
  s.social_media_url = 'https://twitter.com/x2on'
  s.screenshot   = 'https://raw.github.com/x2on/FSImageViewer/master/screen.png'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "sirajudheen" => "sirajudheen@qburst.com" }
  s.source           = { :git => "https://github.com/sirajudheen53/FSImageViewer.git", :tag => s.version.to_s }
  
  s.platform     = :ios, '6.0' 
  s.requires_arc = true

  s.source_files = 'FSImageViewer/'
  s.resources = 'FSImageViewer.bundle'

  s.frameworks = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore', 'Security', 'CFNetwork'
  s.dependency 'AFNetworking', '~> 2.2'
  s.dependency 'EGOCache', '~> 2.0'
end
