require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'floorp' }

target.build_configurations.each do |config|
  s = config.build_settings
  # 正しい plist ファイル名を指定
  s['INFOPLIST_FILE'] = 'floorp/floorp-Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
end

project.save
puts "Project settings fixed to use floorp-Info.plist."
