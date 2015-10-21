# FakeGoUp
If you need add fake favor's count, you could use this gem。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fake_go_up'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fake_go_up

## Usage

you should init the redis before your app star, like this
```ruby
FakeGoUp.redis = $redis #$redis is your redis instance
```

then, you should define your own voter under `lib/voters`。such as `test_voter.rb`
each voter should do things as little as possible. each interval`s unit is at least 1 second. 
it is simple，and it is not parallel !!!
```ruby
#lib/voters/test_voter.rb
class TestVoter < FakeGoUp
    max_fake_count 20 #max fake count per interval, default is 20
    interval 1 #seconds per interval
    def process(item, fake_count)
        #you should overwrite this func, and item is a active record project
    end
end
```

then you should run a rake per 5-10 times, like this
```ruby
#lib/tasks/fake_go_up.rake
namespace :fake_go_up do
  task :run => :environment do
    FakeGoUp.run
  end
end
```
`FakeGoUp.run` will never stop until all jobs finish. you should run a rake to check if there is new jobs. if there is a running fake_go_up, if will not star a new fake_go_up.

now `TestVoter` provide theses func
```
t = TestVoter.new
TestVoter.remain(t) # => the t`s remain fake count needs to add
TestVoter.running?(t) # => if the t`s fake_go_up is running? 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fake_go_up. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

