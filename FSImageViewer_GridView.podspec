#
# Be sure to run `pod lib lint FSImageViewer_GridView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FSImageViewer_GridView"
  s.version          = "4.1.3"
  s.summary          = "Library added additonal functionality on FSImageViewer_image_details."
  s.description      = "Added option to display gridview initially. Use the showGridView parameter for this purpose"
  s.homepage         = "https://github.com/freshbrix/FSImageViewer"
  s.screenshots     = "https://raw.github.com/x2on/FSImageViewer/master/screen.png"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "freshbrix" => "freshbrix@gmail.com" }
  s.source           = { :git => "https://github.com/freshbrix/FSImageViewer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/x2on'

  s.platform     = :ios, '6.0'
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
