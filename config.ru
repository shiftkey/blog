require "rack/rewrite"
require 'rack/contrib/try_static'
require 'rack/contrib/not_found'
require 'rack/static'
require 'rack/deflater'
require './cache-response'

use Rack::Rewrite do
	rewrite '/feed/', '/rss.xml'
	rewrite '/blog/feed/', '/rss.xml'
    rewrite %r{/(.+)}, lambda {     |match, rack_env| 
        if File.exists?('_site/' + match[1] + '.html')
            return '/' + match[1] + '.html' 
        else
            return '/' + match[1]
        end
    }
end

use CacheSettings, {
  /\/js\// => { :cache_control => "max-age=86400, public", :expires => 86400 },
  /\/css\// => { :cache_control => "max-age=86400, public", :expires => 86400 },
  /\/img\// => { :cache_control => "max-age=86400, public", :expires => 86400 }
}

use Rack::TryStatic,
  :root => "_site",
  :urls => %w[/],
  :try  => ['index.html', '/index.html']
use Rack::Deflater

run Rack::NotFound.new('_site/404.html')