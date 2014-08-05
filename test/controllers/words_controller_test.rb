require 'test_helper'

class WordsControllerTest < ActionController::TestCase
  test "learn method passes a random word" do
    random_word = Word.new(pl:'czesc', eng:'hello')
		Word.expects(:random).returns(random_word)
		get 'learn'
		assert_equal random_word, assigns('word')
		assert_tag tag:'div', child: /czesc/
		assert_tag tag:'div', child: /hello/
	end
end
