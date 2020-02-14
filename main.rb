require 'sinatra'
require 'sinatra/reloader' # shit

also_reload 'db/shared'
also_reload 'models/dish'

require 'pry'

enable :sessions

require_relative 'db/shared'
require_relative 'models/dish'
require_relative 'models/user'
# require_relative 'models/comment'
# require_relative 'models/venues'


get '/' do
  @dishes = all_dishes()
  erb :index
end

get '/login' do
  erb :login
end

post '/login' do
  # select database
  # check the record exists for the email the user sent in
  sql = "select * from users where email = '#{ params[:email] }';"
  results = run_sql(sql)

  # check record exists for email and password digested match
  if results.count == 1 && BCrypt::Password.new(results[0]['password_digest']) == (params[:password])

    # write down who you are - creating a session for you
    session[:user_id] = results[0]['id']

    redirect '/'  # up to you
  else
    erb :login
  end
end

# this endpoint is intended for normal form request
post '/likes' do
  run_sql(
    'insert into likes (user_id, dish_id) values ($1, $2);', 
    [session[:user_id], params[:dish_id]]
  )
  redirect "/dishes/#{ params[:dish_id] }"
end

# use this endpoint - making request using js
post '/api/likes' do
  run_sql(
    'insert into likes (user_id, dish_id) values ($1, $2);', 
    [session[:user_id], params[:dish_id]]
  )
  results = run_sql('select count(*) as likes_count from likes where dish_id = $1', [params[:dish_id]])
  # redirect "/dishes/#{ params[:dish_id] }"
  { likes_count:  results[0]['likes_count'] }.to_json
end

require_relative 'controllers/dishes_controller'
# require_relative 'controllers/comments_controller'
# require_relative 'controllers/venues_controller'





