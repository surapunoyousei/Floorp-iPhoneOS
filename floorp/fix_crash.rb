require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  target.build_configurations.each do |config|
    s = config.build_settings
    # クラッシュの原因になりそうな全てのカスタムキーを徹底的に削除
    keys_to_delete = s.keys.select { |k| k.start_with?('INFOPLIST_KEY_') || k.include?('UIScene') }
    keys_to_delete.each do |k|
      puts "Deleting key: #{k} from target #{target.name}"
      s.delete(k)
    end
  end
end

project.save
puts "Deep clean complete. Xcode should really open now."
