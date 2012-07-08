require "rack/jekyll"
require "rack/rewrite"

use Rack::Rewrite do
	#r302 '/build/migration-tips-and-tricks.html', '/2012/03/07/winrt-api-design-notes.html'
    #r302 '/build/customise-a-winmd-file.html', '/2012/03/07/customise-a-winmd-file.html'
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