require 'webrick'
require 'dbi'
require 'pry'
config = {
  :Port => 8080,
  :DocumentRoot => '.'
  }

server = WEBrick::HTTPServer.new(config)

server.mount_proc "/" do |req, res|
  res.body = <<EOF
    <!DOCTYPE html>
    <html><body><head><meta charset="utf-8"></head>
      <form action="/bookmarks" method="post">
        サイト名:<input type="text" name="site_name">
        URL:<input type="text" name="url">
        <input type="submit" value="登録">
      </form>
    </body></html>
EOF
end

server.mount_proc "/bookmarks" do |req, res|
  dbh = DBI.connect('DBI:SQLite3:bookmarks.db')
  dbh.do("insert into bookmarks values ('#{req.query["site_name"]}', '#{req.query["url"]}')")
  dbh.disconnect

  res.body = '<html><body><head><meta charset="utf-8"></head>'
  
  dbh = DBI.connect('DBI:SQLite3:bookmarks.db')
  dbh.select_all("select * from bookmarks") do |row|
    res.body << "<a href=\'#{row["url"]}\'> #{row["site_name"]} </a>" + '<br>'
  end

  res.body << "</body></html>"
  dbh.disconnect

end

trap(:INT) do
  server.shutdown
end

server.start
  