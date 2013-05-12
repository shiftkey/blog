#Derived from https://github.com/avdgaag/arjanvandergaag.nl/blob/28539bc736a05b28f2aa4ef81e4f61f3f91375a0/Rakefile
task :default => :dev

namespace :assets do
  desc 'Precompile assets'
  task :precompile do
    sh "bundle exec jekyll build"
  end
end

desc 'Run Jekyll in development mode'
task :dev do
  puts '* Running Jekyll with auto-generation and server'
  puts `jekyll serve auto`
end

desc 'Run Jekyll to generate the site'
task :build do
  puts '* Generating static site with Jekyll'
  puts `jekyll build`
end

desc 'Push source code to remotes'
task :push do
  puts '* Pushing to GitHub'
  puts `git push origin master`
  
  puts '* Pushing to heroku'
  puts `git push heroku master`
end