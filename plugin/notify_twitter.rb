#
# Copyright (C) 2007 peo <peo@mb.neweb.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
require 'net/http'

module Twitter
	URL = 'twitter.com'
	PATH = '/statuses/update.json'

	class Updater

		def initialize( user, pass )
			@user = user
			@pass = pass
		end

		# this code is based on http://la.ma.la/blog/diary_200704111918.htm
		def update( status )
			Net::HTTP.version_1_2
			req = Net::HTTP::Post.new(PATH)
			req.basic_auth(@user, @pass)
			req.body = 'status=' + URI.encode(status, /[^-.!~*'()\w]/n)

			Net::HTTP.start(URL, 80) {|http|
					res = http.request(req)
			}
		end
	end
end

def notify_twitter
	date = @date.strftime('%Y%m%d')

	diary = @diaries[date]
	titles = []
	diary.each_section do |sec|
		titles << sec.subtitle
	end
	sectitles = titles.join(', ')
	blogtitle = @conf.html_title
	url = @conf.base_url + anchor(date)

	format = @conf['twitter.notify.format'] || '%s%s : %s %s'
	prefix = @conf['twitter.notify.prefix'] || '[blog update] ' # '[diary update] '
	status = format % [prefix, blogtitle, sectitles, url]
	#STDERR.puts status

	user = @conf['twitter.user']
	pass = @conf['twitter.pass']
	twupdater = Twitter::Updater.new(user, pass)
	twupdater.update( status )
end

add_update_proc do
	notify_twitter if @cgi.params['notify_twitter'][0] == 'true'
end

add_edit_proc do
	checked = ' checked'
	if @mode == 'preview' then
		checked = @cgi.params['notify_twitter'][0] == 'true' ? ' checked' : ''
	end
	<<-HTML
	<div class="notify_twitter">
	<input type="checkbox" name="notify_twitter" value="true"#{checked} tabindex="400">
	Post the update to Twitter
	</div>
	HTML
end

# vim:ts=3
