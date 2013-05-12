require "rack/rewrite"
require 'rack/contrib/try_static'
require 'rack/contrib/not_found'
require 'rack/cache'
require 'rack/static'
require 'rack/deflater'
require 'dalli'

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

use Rack::Static,
  :urls => ["/img", "/js", "/css"],
  :root => "_site"
use Rack::Deflater


$cache = Dalli::Client.new

use Rack::Cache,
  :verbose => true,
  :metastore => $cache,
  :entitystore => $cache

use Rack::TryStatic,
  :root => "_site",
  :urls => %w[/],
  :try  => ['index.html', '/index.html']
 
run Rack::NotFound.new('_site/404.html')