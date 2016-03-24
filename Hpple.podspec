Pod::Spec.new do |s|
  s.name         = "hpple"
  s.version      = "0.4.0"
  s.summary      = "A nice Objective-C wrapper on the XPathQuery library for parsing HTML."
  s.homepage     = "http://topfunky.com"
  s.license      = 'MIT'
  s.authors      = { "Geoffrey Grosenbach" => "boss@topfunky.com", "Emma Blink" => "leaf.node@icloud.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/0x1eaf/hpple.git", :tag => s.version.to_s }
  s.source_files  = 'Pod/Classes', 'Pod/Classes/**/*.{h,m}'
  s.ios.libraries = 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  s.requires_arc = true
  s.module_name = "Hpple"
end
