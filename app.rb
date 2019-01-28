# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"

enable :method_override

def rewrite_json
  File.open("hoge.json", "w") do |file|
    JSON.dump(@memos, file)
  end
end

def load_file
  File.open("hoge.json") do |file|
    @memos = JSON.parse(file.read)
  end
end

def load_element
  File.open("hoge.json") do |file|
    @memos = JSON.parse(file.read)
    number = params["id"].to_i
    @memo = @memos[number - 1]
  end
end

get "/" do
  load_file
  erb :index
end

get "/new_memo" do
  erb :new_memo
end

get "/memo/:id" do
  load_element
  erb :show_memo
end

post "/new_memo" do
  load_file
  File.open("hoge.json") do |file|
    hash_number = JSON.load(file).count
    params["id"] = hash_number + 1
  end

  @memos.push(params)
  rewrite_json
  redirect "/"
  erb :index
end

delete "/memo/delete/:id" do
  load_element
  @memo.clear
  @memos.delete({})

  @memos.each do |memo|
    memo["id"] -= 1 if memo["id"] > params["id"].to_i
  end

  rewrite_json
  redirect "/"
  erb :index
end

get "/memo/edit/:id" do
  load_element
  erb :edit_memo
end

patch "/memo/edit_memo/:id" do
  load_element
  @memos.each do |memo|
    if memo["id"] == params["id"].to_i
      memo["title"] = params["title"]
      memo["memo"] = params["memo"]
    end
  end

  rewrite_json
  redirect "/"
  erb :index
end
