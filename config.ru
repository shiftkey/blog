#require "rack/jekyll"
#require "rack/rewrite"
require 'rack/contrib/try_static'
require 'rack/contrib/not_found'

#use Rack::Rewrite do
#	rewrite '/feed/', '/rss.xml'
#	rewrite '/blog/feed/', '/rss.xml'
#    rewrite %r{/(.+)}, lambda {     |match, rack_env| 
#        if File.exists?('_site/' + match[1] + '.html')
#            return '/' + match[1] + '.html' 
#        else
#            return '/' + match[1]
#        end
#    }
#end
 
use Rack::TryStatic,
  :root => "_site",
  :urls => %w[/],
  :try  => ['index.html', '/index.html']
 
run Rack::NotFound.new('_site/404.html')