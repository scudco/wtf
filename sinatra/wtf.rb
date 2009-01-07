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

