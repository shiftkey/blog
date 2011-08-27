require 'rubygems'
require 'sequel'
require 'fileutils'
require 'yaml'

module Jekyll
  module FunnelWeb
    #C:\Code\leagueofpaulblog>ruby -r './_import/funnelweb.rb' -e 'Jekyll::FunnelWeb.process("ODIN\\SQLEXPRESS", "test2", "test123", "pauldb")'
    def self.process(host, user, pass, database)
    	puts 'Starting...'
      	db = Sequel.odbc(:server => host, :user=>user, :password=>pass, :driver=>'SQL Server', :database=>database, :encoding => 'UTF-8')
      	FileUtils.mkdir_p("_posts")
  
	 	query = " SELECT E.Title,
                      E.Published,
                      E.Name,
                      E.MetaDescription,
                      E.Id,
                      E.Status,
                      E.IsDiscussionEnabled
              	FROM Entry E"
        output =""
      
  		db[query].each do |post|
				title = post[:name]
				date = post[:published]

				
				revisionQuery = "SELECT TOP (1) Body FROM Revision WHERE EntryId = %s ORDER BY RevisionNumber DESC" % post[:id]
				content = ""
				db[revisionQuery].each do |revision|
				  content += revision[:body]
				end

				content.gsub!("\r".force_encoding("UTF-8"), '')

				#grab all the tags
				tagQuery = "SELECT Name FROM TagItem JOIN Tag ON Tag.Id = TagItem.TagId WHERE EntryId = %s" % post[:id]
				tagstring = ""
				db[tagQuery].each do |tag|
				  tagstring += tag[:name] + " "
				end

				# to YAML for the header.
				data = {
				 'layout' => 'post',
				 'title' => post[:title].to_s,
				 'description' => post[:metadescription].to_s,
				 'funnelweb_id' => post[:id],
				 'date' => date,
				'tags' => tagstring,
				'comments' => (post[:isdiscussionenabled] == 1 ? true : false)
				}.delete_if { |k,v| v.nil? || v == '' }.to_yaml

				#this would be an "rss" item, or something that appears on the main page
				if post[:status] == "Public-Blog"
				  name = "%02d-%02d-%02d-%s.md" % [date.year, date.month, date.day, title]
				  File.open("_posts/#{name}", "w") do |f|
					f.puts data
					f.puts "---"
					f.puts content
				  end
				end

				#about page, etc
				if post[:status] == "Public-Page"
				  name = "%s.md" % title
				  File.open("#{name}", "w") do |f|
					f.puts data
					f.puts "---"
					f.puts content
				  end
				end
      end
    end
  end
end

