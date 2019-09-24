namespace :josiah do
  task "tests" => :environment do |_cmd, args|
    Dir.glob("./test/**/*_test.rb").each do |test_file|
        require test_file
      end
    end
end
