require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)
app_target = project.targets.find { |t| t.name == 'floorp' }

def fix_extension_paths(project, name)
  puts "Updating paths for: #{name}..."
  ext_target = project.targets.find { |t| t.name == name }
  return unless ext_target

  ext_target.build_configurations.each do |config|
    s = config.build_settings
    # 新しい場所（floorp/直下）を指すように修正
    s['INFOPLIST_FILE'] = "ExtensionsSource/#{name}/Info.plist"
    s['CODE_SIGN_ENTITLEMENTS'] = "ExtensionsSource/#{name}/#{name}.entitlements"
  end
end

fix_extension_paths(project, 'WebContent')
fix_extension_paths(project, 'Networking')
fix_extension_paths(project, 'Rendering')

# メインアプリのリソースから Info.plist を除外（念のためのダメ押し）
app_target.resources_build_phase.files.each do |f|
  if f.file_ref && f.file_ref.path && f.file_ref.path.include?('Info.plist')
    puts "Removing redundant plist reference: #{f.file_ref.path}"
    app_target.resources_build_phase.remove_build_file(f)
  end
end

project.save
puts "Paths updated and conflicts cleared."
