Based on Andrzej Krzywda's [post](http://andrzejonsoftware.blogspot.com/2007/05/15-tdd-steps-to-create-rails.html), *"15 TDD steps to create a Rails Application"* which is recommended in the Rails Guide *[A guide to testing rails application](http://guides.rubyonrails.org/testing.html)*. The original post was published in May, 2007 and some codes have since deprecated. I have attempted to update the tutorial here in the hope that it may benefit many people, like it had benefited me. 

This tutorial takes the TDD approach in building a simple word-learning web application, it displays a random word object (with its Polish translation) from the database. Every time we refresh, we see a different word. 

Let's begin
----------
### 1. Create a new Rails application

```
$ rails new my_app

$ cd my_app
```

### 2. Create a Word class with corresponding unit test
```
$ rails g model Word

```

### 3. Prepare your database
```
$ rake db:migrate

$ rake #should now run fine
```

### 4. Write a unit test for the Word class.
Edit the test/models/word_test.rb

```
test 'word is in both English and Polish' do 
    word = Word.new eng:'never', pl:'nigdy'
    assert_equal 'never', word.eng
    assert_equal 'nigdy', word.pl
  end
```

```
$ rake #should throw an error due to missing columns in words table
```

### 5. Add columns to your table

```
$ rails g migration add_eng_and_pl_to_words

```
From your db/migrate folder open the new migration file you just created and add the following columns like so:

```
class AddEngAndPlToWords < ActiveRecord::Migration
  def change
    add_column :words, :eng, :string
    add_column :words, :pl, :string
  end
end
```
```
$ rake db:migrate 

$ rake #error will go away
```

Enter rails console 

```
$ rails c

$ Word.create(eng:'yes', pl:'tak')

$ Word.create(eng:'no', pl:'nie')

$ Word.create(eng:'everything', pl:'wszystko')

```

This will create the three words with its Polish translation.

```
$ exit  #exit the console

$ rake  #should now run fine

```
### 6. Fixtures and test for word.random. 

Edit test file again. The test/models/word_test.rb file should now look like this:

```
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
```

Edit the words.yml file (in the fixtures folder) to look like this:

```
false: 
  eng: "no"
  id: 2
  pl: nie
true: 
  eng: "yes"
  id: 1
  pl: tak
```

Be careful with the spacing. YML files are like crazy annoying people, they'll yell at you if you miss a space. Head over to <http://yamllint.com/> and validate your yaml if unsure or learn more here: <http://ess.khhq.net/wiki/YAML_Tutorial>

```
$ rake  #should throw an error because of undefined method 'random'
```
### 7. Implement the Word.random method
In your app/models/word.rb implement the word.random method like so:

```
class Word < ActiveRecord::Base
  def self.random
    all = Word.all
    all[rand(all.size)]
  end
end

```
```
$ rake  #should now run fine
```



### 8. Generate the Words controller with a 'learn' action
```
$ rails g controller Words learn
```

### 9. Write a test for the learn method.
Just as there is one-to-one ratio between unit tests and models, so there is between functional tests and controllers. The Controller's responsibility is to retrieve objects from the Model layer and pass them to the View. Let's test the View part first. We use the 'assigns' collection which contains all the objects passed to the View.

In the test/controllers/words_controller_test.rb

```
require 'test_helper'

class WordsControllerTest < ActionController::TestCase
  test "learn method passes a random word" do
    get 'learn'
    assert_kind_of Word, assigns('word')
  end
end
```
```
$ rake #test will have 1 failure
```

### 10. Make the Test Pass

In your app/controllers/words_controller.rb

```
class WordsController < ApplicationController
  def learn
    @word = Word.new
  end
end
```


### 11. Write more tests in the words_controller_test
How can we test that the controller uses the Word.random method? We don't want to duplicate the tests for the Word.random method. Mocks to the rescue! We will only test that the controller calls the Word.random method. The returned value will be faked with a prepared word. Let's install the mocha framework.

In your Gemfile 

```
group :test, :development do
  gem 'mocha'
end
```

We can now use 'expects' and 'returns' methods. 'expects' is used for setting an expectation on an object or a class. In this case we expect that the 'random' method will be called. We also set a return value by using 'returns' method. Setting a return value means faking (stubbing) the real method. The real Word.random won't be called. If an expectation isn't met; the test fails.

```
require 'test_helper'

class WordsControllerTest < ActionController::TestCase
  test "learn method passes a random word" do
    random_word = Word.new
    Word.expects(:random).returns(random_word)
    get 'learn'
    assert_equal random_word, assigns('word')
  end
end
```
```
$ rake  #should now run fine
```
### 12. Rewrite the implementation
Edit words_controller.rb

```
def learn
  @word = Word.random
end
```
```
$ rake  #should now run fine
```



### 13. Test that a word is displayed: Extend the existing test with assert_tag calls.
Edit words_controller_test.rb

```
test "learn method passes a random word" do
  random_word = Word.new(pl:'czesc', eng:'hello')
  Word.expects(:random).returns(random_word)
  get 'learn'
  assert_equal random_word, assigns('word')
  assert_tag tag:'div', child: /czesc/
  assert_tag tag:'div', child: /hello/
end
```

### 14. Implement the view 
In app/views/words/learn.html.erb

```
<div>
  <%= @word.eng %>
  <%= @word.pl %>
</div>
```
```
$ rake #should now run fine
```

### 15. Manual testing
```
$ rails server
```
Go to http://localhost:3000/words/learn 
Refresh several times to see different words.

Published with permission of  [Andrzej Krzywda](https://twitter.com/andrzejkrzywda/status/496802403279450112). I have also created a sample app with the same tutorial, the source code can be found here: <https://github.com/vajradog/15-TDD-steps-revised>

Related articles:
[Some more TDD steps with Rails Testing](http://andrzejonsoftware.blogspot.com/2007/05/and-some-more-tdd-steps-with-rails.html), [Rails controllers with mock objects](http://andrzejonsoftware.blogspot.com/2007/06/testing-rails-controllers-with-mock.html) If you want to read more about testing in Rails go to the [Guide To Testing The Rails.](http://manuals.rubyonrails.com/read/book/5)