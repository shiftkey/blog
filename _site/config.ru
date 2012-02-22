require "rack/jekyll"
require "rack/rewrite"

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

use Rack::Static, :urls => ["/css", "/img", "/js" ]

run Rack::Jekyll.new