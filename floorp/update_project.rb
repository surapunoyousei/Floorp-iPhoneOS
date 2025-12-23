require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  next if target.name == 'floorp' # メインアプリ以外
  
  puts "Deepening rpath for Extension: #{target.name}"
  target.build_configurations.each do |config|
    s = config.build_settings
    # 既存のパスに加え、XULが潜んでいる深い階層も追加
    s['LD_RUNPATH_SEARCH_PATHS'] = [
      '$(inherited)',
      '@executable_path/Frameworks',
      '@executable_path/../../Frameworks',
      '@executable_path/../../Frameworks/GeckoView.framework/Frameworks'
    ].uniq
  end
end

project.save
puts "Extension rpaths deepened successfully."
