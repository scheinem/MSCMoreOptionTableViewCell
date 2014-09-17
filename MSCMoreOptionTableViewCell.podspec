Pod::Spec.new do |s|
  s.name         = "MSCMoreOptionTableViewCell"
  s.version      = "2.1"
  s.summary      = "Drop-in solution to achieve the \"More\" button in an UITableView's \"Swipe to Delete\" menu (as seen in Mail.app under iOS 7). Fully compatible to iOS 7 and iOS 8."
  s.homepage     = "https://github.com/scheinem/MSCMoreOptionTableViewCell"
  s.screenshot   = "https://raw.github.com/scheinem/MSCMoreOptionTableViewCell/master/MSCMoreOptionTableViewCell.png"
  s.license      = 'MIT'
  s.author       = { "Manfred Scheiner" => "sayhi@scheinem.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/scheinem/MSCMoreOptionTableViewCell.git", :tag => "2.1" }
  s.source_files  = 'MSCMoreOptionTableViewCell/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true
end
