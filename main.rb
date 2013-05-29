require 'rubygems'
require 'sinatra'

set :sessions, true

# methods in helpers block are available in main.rb and view templates
helpers do
	def cards_total(cards)
		total = 0
		new_arr = cards.map{|e| e[0]}
 		new_arr.each do |x|
 			if x == 'Ace'
 				total += 11
 			elsif x.to_i == 0
 				total += 10
 			else
 				total += x.to_i
 			end
 		end

 		new_arr.select{|e| e == 'Ace'}.count.times do
 			total -= 10 if total > 21
 		end
 		
 		total
 	end
end

# run this code before every single action
before do
	@hit_or_stay = true 
end

get '/' do
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end 
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
	session[:player_name] = params[:player_name].capitalize
	redirect '/game'
end

get '/game' do
	#create a deck
	suits = ['Spades', 'Hearts', 'Diamond', 'Clubs']
	values = %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King)
	session[:deck] = values.product(suits).shuffle!

	#deal cards
	session[:player_cards] = []
	session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	if cards_total(session[:player_cards]) > 21
		@error = "Oh, no! Busted! You lose..."
		@hit_or_stay = false
	end
	erb :game
end

post '/game/player/stay' do
	@success = "You choose to stay."
	@hit_or_stay = false
	erb :game
end




