require 'rake/clean'

task :default => :prepare

task :prepare do
  if !File.exists?("/usr/local/arcanist")
    puts "installing arcanist..."
    system("echo 'export PATH=/usr/local/arcanist/bin:$PATH' >> ~/.profile") 
    system("cd /usr/local && git clone git://github.com/facebook/libphutil.git")
    system("cd /usr/local && git clone git://github.com/facebook/arcanist.git")
    puts "done"
    puts "WARNING: You must reload your .profile to get the arc command in your path. If you are not using the BASH shell then you need to add /usr/local/arcanist/bin to your path manually"
  end
end

# This is a workaround for a silly bug in RubyGems on JRuby:
# when running a rakefile as part of an install the 2>&1 redirect ends
# ends up as an argument to Rake, and Rake complains, which makes the
# build fail. The workaround is to declare a task with this name.
task '2>&1' => :defaults