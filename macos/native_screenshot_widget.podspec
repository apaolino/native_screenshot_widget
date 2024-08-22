#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_screenshot_widget.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_screenshot_widget'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to take screenshot(support Platform Views) for Android and iOS with native code.'
  s.description      = <<-DESC
A Flutter plugin to take screenshot(support Platform Views) for Android and iOS with native code.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.osx.dependency 'FlutterMacOS'
  s.osx.deployment_target = '10.14'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
