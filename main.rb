require 'rubygems'
require 'sinatra'

set :sessions, true

# methods in helpers block are available in main.rb and view templates
helpers do
	def cards_total(cards)
		total = 0
		new_arr = cards.map{|e| e[0]}
 		new_arr.each do |x|
 			if x == 'ace'
 				total += 11
 			elsif x.to_i == 0
 				total += 10
 			else
 				total += x.to_i
 			end
 		end

 		new_arr.select{|e| e == 'ace'}.count.times do
 			total -= 10 if total > 21
 		end
 		
 		total
 	end

 	def cards_image(cards)
 		"<img src= '/images/cards/#{cards[1]}_#{cards[0]}.jpg' class='cards_image'>"
 	end

 	def win!(msg)
 		@hit_or_stay = false
 		session[:bank] += session[:bet_amount]
 		@success = "<strong>#{msg} Congratulations, you won!</strong>"
 		@play_again = true
 	end

 	def lose!(msg)
 		@hit_or_stay = false
 		session[:bank] -= session[:bet_amount]
 		@error = "<strong>#{msg} On, no! You lost.</strong>"
 		@play_again = true
 	end

 	def tie!(msg)
 		@hit_or_stay = false
 		@success = "<strong>#{msg} Tied!</strong>"
 		@play_again = true
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
	if params[:player_name].empty?
		@error = 'Name is required.'
		halt erb(:new_player)  #stop executing below and run the specific action
	end

	session[:bank] = 1000
	session[:player_name] = params[:player_name].capitalize
	redirect '/bet'
end

get '/bet' do
	session[:bet_amount] = nil
	erb :bet
end

post '/bet' do
	if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
		@error = "Bet required."
		halt erb(:bet)
	elsif params[:bet_amount].to_i > session[:bank]
		@error = "Exceeds the max amount."
		halt erb(:bet)
	else
		session[:bet_amount] = params[:bet_amount].to_i
		redirect '/game'
	end
end


get '/game' do
	@show_dealer_card = false

	#create a deck
	suits = ['spades', 'hearts', 'diamonds', 'clubs']
	values = %w(ace 2 3 4 5 6 7 8 9 10 jack queen king)
	session[:deck] = values.product(suits).shuffle!

	#deal cards
	session[:player_cards] = []
	session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  if cards_total(session[:player_cards]) == 21
  	win!('You hit blackjack!')
  end

  if cards_total(session[:dealer_cards]) == 21
  	lose!('Dealer hit blackjack')
  end

	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	player_total = cards_total(session[:player_cards])
	
	if player_total == 21
		win!('You hit blackjack!')
	end
	
	if player_total > 21
		lose!('You busted!')
	end

	erb :game
end

post '/game/player/stay' do
	@success = 'You have chosen to stay.'
	@hit_or_stay = false
	redirect '/game/dealer'
end

get '/game/dealer' do
	@show_dealer_card = true
	@hit_or_stay = false
	dealer_total = cards_total(session[:dealer_cards])

	if dealer_total == 21
		lose!("Dealer hit blackjack.")
	elsif dealer_total > 21
		win!("Dealer busted at #{dealer_total}.")
	elsif dealer_total >= 17
		redirect '/game/compare'
	else
		@dealer_hit = true
	end

	erb :game
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect '/game/dealer'
end

get '/game/compare' do
	@hit_or_stay = false
	player_total = cards_total(session[:player_cards])
	dealer_total = cards_total(session[:dealer_cards])

	if player_total > dealer_total
		win!("You have #{player_total} and dealer has #{dealer_total}.")
	elsif player_total < dealer_total
		lose!("You have #{player_total} and dealer has #{dealer_total}.")
	else
		tie!("Both you and dealer stay at #{player_total}.")
	end
		
	erb :game
end

get '/game_over' do
	erb :game_over
end