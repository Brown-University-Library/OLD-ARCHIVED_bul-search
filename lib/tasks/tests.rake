namespace :josiah do
  desc "Unit tests (and solr relevance tests)"
  task "tests" => :environment do |_cmd, args|
    Dir.glob("./test/**/*_test.rb").each do |test_file|
        require test_file
      end
    end
end
