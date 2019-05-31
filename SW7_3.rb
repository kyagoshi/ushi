require 'webrick'
require 'dbi'

config = {
 :Port =>8080,
 :DocumentRoot => '.'
 }
 
server = WEBrick::HTTPServer.new(config)
 
server.mount_proc"/" do |req, res|
  res.body = <<EOF
    <!DOCTYPE html>
    <html><body><head><meta charset="utf-8"></head>
    <form action="/names" method="post">
      名前:<input type="text" name="name">
      <input type="submit" value="登録">
    </form>
    </body></html>
EOF
end
 
  server.mount_proc "/names" do |req, res|
    #DBにデータ登録
    dbh = DBI.connect('DBI:SQLite3:names.db')
    dbh.do("insert into names_tbl values ('#{req.query["name"]}')")
    dbh.disconnect

     #DBのデータ表示
     res.body = '<html><body><head><meta charset="utf-8"></head>'

     dbh = DBI.connect('DBI:SQLite3:names.db')
     dbh.select_all("select * from names_tbl") do |row|
         res.body<<row[0] + '<br>'
     end
     res.body << "</body></html>"
     dbh.disconnect
end

 trap(:INT) do
  server.shutdown
  end

  server.start