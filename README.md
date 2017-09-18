How to set up continuos deployment with Capistrano and CircleCI
============

The following instructions are complied from:
* My own experience
* [Capistrano's GitHub](https://github.com/capistrano/capistrano)
* [Capistrano-Symfony's GitHub](https://github.com/capistrano/symfony)
* [A Medium post by tomnewbyau](https://medium.com/@tomnewbyau/continuous-delivery-with-symfony-circleci-capistrano-add0df48347d)
* [A Medium post by jontorrado](https://medium.com/@jontorrado/deploying-a-symfony-application-with-capistrano-a954a1a03819)

1. [install ruby](https://www.ruby-lang.org/en/documentation/installation/)
2. [install bundler](https://bundler.io/)

```bash
gem install bundler
```

3. create Gemfile

```ruby
source 'https://rubygems.org' do
    gem 'capistrano',  '~> 3.9'
    gem 'capistrano-symfony', '~> 1.0.0.rc2'
end
```

4. install capistrano

```bash
bundle install
```

5. capify your project
Set `STAGES` to a comma separated list of all your environments.
This will create your deployment config files.

```bash
bundle exec cap install STAGES=prod,test,...
```
