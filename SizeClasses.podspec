#
# Be sure to run `pod lib lint SizeClasses.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SizeClasses'
  s.version          = '0.4.0'
  s.summary          = 'Use size classes in programmatic layouts effectively.'

  s.homepage         = 'https://github.com/Eckelf/SizeClasses'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vincent Flecke' => 'opensouce@eckgen.com' }
  s.source           = { :git => 'https://github.com/Eckelf/SizeClasses.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'

  s.source_files = 'SizeClasses', 'SizeClasses/**/*.swift'
end
