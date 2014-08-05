class Word < ActiveRecord::Base
	def self.random
		all = Word.all
		all[rand(all.size)]
	end
end
