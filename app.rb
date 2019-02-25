# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"

enable :method_override

def load_file(file_name)
  File.open(file_name) do |file|
    JSON.parse(file.read)
  end
end

def rewrite_json(file_name, hash_object)
  File.open(file_name, "w") do |file|
    JSON.dump(hash_object, file)
  end
end 

def number
  params["id"].to_i
end

get "/" do
  @memos = load_file("hoge.json")
  erb :index
end

get "/new_memo" do
  erb :new_memo
end

get "/memo/:id" do
  @memos = load_file("hoge.json")
  number 
  @memo = @memos[number - 1]
  erb :show_memo
end

post "/new_memo" do
  @memos = load_file("hoge.json")
  File.open("hoge.json") do |file|
    hash_number = JSON.load(file).count
    params["id"] = hash_number + 1
  end

  @memos.push(params)
  rewrite_json("hoge.json", @memos)
  redirect "/"
  erb :index
end

delete "/memo/delete/:id" do
  @memos = load_file("hoge.json")
  number
  @memo = @memos[number - 1]

  @memo.clear
  @memos.delete({})

  @memos.each do |memo|
    memo["id"] -= 1 if memo["id"] > params["id"].to_i
  end

  rewrite_json("hoge.json", @memos)
  redirect "/"
  erb :index
end

get "/memo/edit/:id" do
  @memos = load_file("hoge.json")
  number
  @memo = @memos[number - 1]
  erb :edit_memo
end

patch "/memo/edit_memo/:id" do
  @memos = load_file("hoge.json")
  number
  @memo = @memos[number - 1]
  @memos.each do |memo|
    if memo["id"] == params["id"].to_i
      memo["title"] = params["title"]
      memo["memo"] = params["memo"]
    end
  end

  rewrite_json("hoge.json", @memos)
  redirect "/"
  erb :index
end
