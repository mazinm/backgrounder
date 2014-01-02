class SessionsController < ApplicationController
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
  
  def gettweets
    @client = Twitter::REST::Client.new do |config|
       config.consumer_key = "dJEtIoFxjo17pvRIgpzRg"
      logger.debug ENV['CONSUMER_KEY']
       config.consumer_secret = "2zqn3EZfJwPpLGrtwslUTSaIytqWoUHPYy8nqjsOuus"
      logger.debug ENV['CONSUMER_SECRET']
       config.access_token = "48182804-jp4uof0n3EGcRd5wASx9GAeQKc9wGgkyytWKL6ZJa"
      logger.debug ENV['ACCESS_TOKEN']
       config.access_token_secret = "7OIERKlexBEXm2Iv58sqTMGiXTaF2m4bwNhouTNRT10Nq"
      logger.debug ENV['ACCESS_TOKEN_SECRET']
     end
  end
end