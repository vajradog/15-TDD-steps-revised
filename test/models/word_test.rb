require 'test_helper'

class WordTest < ActiveSupport::TestCase
	fixtures :words

  test 'word is in both English and Polish' do 
  	word = Word.new eng:'never', pl:'nigdy'
  	assert_equal 'never', word.eng
  	assert_equal 'nigdy', word.pl
  end

	test 'show random words' do
		results = []
		10.times {results << Word.random.eng}
		assert results.include?("yes")
	end

end
