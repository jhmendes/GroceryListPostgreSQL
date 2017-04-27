require "sinatra"
require "pg"
require 'pry'

set :bind, '0.0.0.0'  # bind to all interfaces

configure :development do
  set :db_config, { dbname: "grocery_list_development" }
end

configure :test do
  set :db_config, { dbname: "grocery_list_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end


get "/" do
  redirect "/groceries"
end

get "/groceries" do
  @groceries = db_connection { |conn| conn.exec("SELECT id, name FROM groceries") }
  erb :groceries
end

get "/groceries/:id" do

  @item = params[:id]

  @name = db_connection { |conn| conn.exec("SELECT groceries.name FROM groceries LEFT JOIN comments ON
    comments.grocery_id = groceries.id WHERE groceries.id = '#{@item}'") }.to_a

  @comments = db_connection { |conn| conn.exec("SELECT groceries.name, comments.body FROM comments RIGHT JOIN groceries ON
    comments.grocery_id = groceries.id WHERE groceries.id = '#{@item}'") }.to_a
  erb :item

end

get "/groceries/:id/edit" do
  @id = params[:id]
  @name = db_connection { |conn| conn.exec("SELECT groceries.name FROM groceries LEFT JOIN comments ON
    comments.grocery_id = groceries.id WHERE groceries.id = '#{@id}'") }.to_a

  erb :edit
end



post "/groceries" do

  item = params["name"]

  db_connection do |conn|
    if item == ""
      redirect "/groceries"
    else
      conn.exec_params("INSERT INTO groceries (name) VALUES ($1)", [item])
    end
  end

  redirect "/groceries"

end

delete "/groceries/:id" do

  @id = params[:id].to_s

  db_connection {|conn| conn.exec("
    DELETE FROM comments
    WHERE comments.grocery_id IS NOT NULL
    AND comments.grocery_id =  '#{@id}'
    ")}


  db_connection { |conn| conn.exec_params("DELETE FROM groceries WHERE groceries.id = '#{@id}'") }

  redirect "/groceries"
  erb :groceries

end

patch "/groceries/:id" do
  @id = params[:id]

  @new_name = params[:name]
  db_connection { |conn| conn.exec("UPDATE groceries
    SET name = '#{@new_name}'
    WHERE groceries.id = '#{@id}'") }
    redirect "/groceries"
    erb :groceries
end
