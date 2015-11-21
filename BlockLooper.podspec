Pod::Spec.new do |s|

  s.name         = "BlockLooper"
  s.version      = "0.0.3"
  s.summary      = "Helper class that lets you loop a closure until you tell it to stop. In Swift."

  s.homepage     = "http://github.com/al7/BlockLooper"
  s.license      = "MIT"
  s.author       = { "Alex Leite" => "admin@al7dev.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/al7/BlockLooper.git", :tag => "0.0.3" }
  s.source_files = "BlockLooper/Source", "BlockLooper/Source/**/*.{h,m,swift}"
  s.requires_arc = true

end
