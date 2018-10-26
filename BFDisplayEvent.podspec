#
# Be sure to run `pod lib lint BFDisplayEvent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://192.168.10.81/IOS/commline/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BFDisplayEvent'
  s.version          = '2.0.1'
  s.summary          = '基于MVVM模式的轻量级解耦框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wans3112/BFDisplayEvent'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wans' => 'wanslm@foxmail.com' }
  s.source           = { :git => 'https://github.com/wans3112/BFDisplayEvent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BFDisplayEvent/Classes/**/*'
  s.prefix_header_contents = "#import <BFDisplayEvent/BFDisplayEvent.h>"

  # s.resource_bundles = {
  #   'BFDisplayEvent' => ['BFDisplayEvent/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency 'CTObjectiveCRuntimeAdditions'


end
