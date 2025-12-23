require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  puts "Updating search paths for: #{target.name}"
  
  target.build_configurations.each do |config|
    s = config.build_settings
    
    # 1. ヘッダーとフレームワークの検索パスを全ターゲットに適用
    s['HEADER_SEARCH_PATHS'] = ['$(inherited)', '$(PROJECT_DIR)/Frameworks/GeckoView.framework/Headers'].uniq
    s['FRAMEWORK_SEARCH_PATHS'] = [
      '$(inherited)', 
      '$(PROJECT_DIR)/Frameworks', 
      '$(PROJECT_DIR)/Frameworks/GeckoView.framework/Frameworks'
    ].uniq
    
    # 2. その他の必須フラグ
    s['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    s['OTHER_LDFLAGS'] = [
      '$(inherited)', 
      '-framework', '"GeckoView"', 
      '$(PROJECT_DIR)/Frameworks/GeckoView.framework/Frameworks/XUL'
    ].uniq
  end
end

project.save
puts "All target search paths updated."
