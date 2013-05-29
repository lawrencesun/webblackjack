require 'rubygems'
require 'sinatra'

set :sessions, true

get '/home' do
	"Hello world!"
end

get '/form' do
  erb :form
end

post '/myaction' do
	puts params['username']
end