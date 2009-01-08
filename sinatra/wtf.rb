require 'rubygems'
require 'sinatra'
require 'dm-core'

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/../wtf.db")

class Wtf
  include DataMapper::Resource

  property :acronym, String, :key => true
  property :definition, Text
end

DataMapper.auto_upgrade!

get '/' do
  erb :index
end

get '/wtf/is/:acronym' do
  @wtf = Wtf.get(params[:acronym].upcase)
  erb :index
end

post '/wtf/is' do
  redirect "/wtf/is/#{params[:acronym]}"
end

get '/wtf/new' do
  erb :new
end

post '/wtf/new' do
  params[:acronym].upcase!
  wtf = Wtf.new(params)
  if wtf.save 
    redirect "/wtf/is/#{params[:acronym]}"
  else
    @error = "Look, this form is not that complicated. Just fill it out right and stop messing around."
    erb :new
  end
end
