Pod::Spec.new do |s|

  s.name         = "BlockLooper"
  s.version      = "0.0.1"
  s.summary      = "Simple Grid View control in swift"

  s.homepage     = "http://github.com/al7/BlockLooper"
  s.license      = "MIT"
  s.author       = { "Alex Leite" => "admin@al7dev.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/al7/BlockLooper.git", :tag => "0.0.1" }
  s.source_files = "BlockLooper/Source", "BlockLooper/Source/**/*.{h,m,swift}"
  s.requires_arc = true

end
