# Esapad

Esapad update your esa page automatically.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'esapad'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install esapad

## Usage
### Edit target page
```markdown
## Blogs
<!-- RECENTLY-UPDATED-FLOW-POSTS-START -->
<!-- RECENTLY-UPDATED-FLOW-POSTS-END -->

## Pages
<!-- RECENTLY-UPDATED-STOCK-POSTS-START -->
<!-- RECENTLY-UPDATED-STOCK-POSTS-END -->

## Recently Popular Entries
<!-- RECENTLY-UPDATED-POSTS-UPDATED-START -->
<!-- RECENTLY-UPDATED-POSTS-UPDATED-END -->
```

### Update target page by esapad
```
$ cp .env.sample .env
$ vim .env
...
ESA_TEAM=yourteam
ESA_ACCESS_TOKEN=abcdefghijklmn
ESA_TARGET_PAGE_ID=1
$ bundle exec ./bin/update-pages-list
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/esapad.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

