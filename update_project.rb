require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'floorp' }

# 全ターゲットのOSバージョンを最新に
project.targets.each do |t|
  t.build_configurations.each { |c| c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.4' }
end

# 埋め込み先の指定を「Extensions (101)」に固定
target.copy_files_build_phases.each do |phase|
  if phase.name.include?('App Extensions')
    phase.dst_subfolder_spec = '101'
  end
end

project.save
puts "Info.plist and Embed paths updated for simulator compatibility."
