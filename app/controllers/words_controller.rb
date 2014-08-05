class WordsController < ApplicationController
  def learn
  	@word = Word.random
  end
end
