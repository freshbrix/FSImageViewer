#
# Be sure to run `pod lib lint FSImageViewer_image_details.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FSImageViewer_GridView"
  s.version          = "1.0"
  s.summary          = "Library added additonal functionality on FSImageViewer_image_details."
  s.description      = "Added details of image such as a note, date overlay and option to mark image private or public."
  s.homepage         = "https://github.com/freshbrix/FSImageViewer"
  s.screenshots     = "https://raw.github.com/x2on/FSImageViewer/master/screen.png"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "freshbrix" => "freshbrix@gmail.com" }
  s.source           = { :git => "https://github.com/freshbrix/FSImageViewer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/x2on'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'FSImageViewer/'
  s.resources = 'FSImageViewer.bundle'
  s.resource_bundles = {'FRResources' => ['Images/*']}
  s.frameworks = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore', 'Security', 'CFNetwork'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'EGOCache', '~> 2.0'
  s.dependency 'SDWebImage', '~> 3.7'
end
