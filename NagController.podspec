# # Be sure to run `pod lib lint SBCategories.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NagController"
  s.version          = "0.0.1"
  s.summary          = "A stateful controller to prompt users to review or upgrade the runnning application"
  s.description      = <<-DESC
		       Presents alert prompting user to upgrade application or submit a review. Customizable for different iTunes URLs and messages
                       DESC
  #s.homepage         = "https://github.com/schrockblock/NagController"
  s.homepage         = "https://github.com/cliffspencer/NagController"
  s.license          = 'MIT'
  s.author           = { "Elliot" => "ephherd@gmail.com" }
  #s.source           = { :git => "https://github.com/schrockblock/NagController.git", :tag => s.version.to_s }
  s.source           = { :git => "https://github.com/cliffspencer/NagController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/schrockblock'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{h,m,swift}'
end
