run 'pgrep spring | xargs kill -9'

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

gem 'devise'
gem 'figaro'
gem 'jbuilder', '~> 2.0'
gem 'pg'
gem 'puma'
gem 'rails', '#{Rails.version}'
gem 'redis'
gem 'webpacker'

gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'jquery-rails'
gem 'sass-rails'
gem 'simple_form'
gem 'uglifier'

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rspec-rails', '~> 3.6'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rails-erd'
  gem 'rubocop', require: false
end

group :test do
  gem 'factory_girl_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'database_cleaner'
end

group :development do
  gem 'annotate'
end

RUBY

# Ruby version
########################################
file '.ruby-version', RUBY_VERSION

# Procfile
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

# Spring conf file
########################################
inject_into_file 'config/spring.rb', before: ').each { |path| Spring.watch(path) }' do
  '  config/application.yml\n'
end

# Assets
########################################
run 'rm -rf app/assets/stylesheets'
run 'rm -rf vendor'
# run 'curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip'
run 'curl -L https://github.com/rodloboz/stylesheets/archive/master.zip > stylesheets.zip'
run 'unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets'

run 'curl -L https://github.com/adrienpoly/rails-templates/archives/css/material-kit.zip > material-kit.zip'
run 'unzip material-kit.zip -d app/assets && rm stylesheets.zip && mv app/assets/material-kit app/assets/stylesheets'

run 'curl -L https://github.com/adrienpoly/rails-templates/archives/js/material-kit.zip > material-kit.zip'
run 'unzip material-kit.zip -d app/assets && rm stylesheets.zip && mv app/assets/material-kit app/assets/js'

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
JS

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>TODO</title>
    <%= csrf_meta_tags %>
    <%= action_cable_meta_tag %>
    <%= stylesheet_link_tag 'application', media: 'all' %>
  </head>
  <body>
    <%= render 'shared/navbar' %>
    <%= render 'shared/flashes' %>
    <%= yield %>
    <%= render 'shared/footer' %>
    <%= javascript_include_tag 'application' %>
    <%= yield(:after_js) %>
  </body>
</html>
HTML

run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/views/shared/_flashes.html.erb > app/views/shared/_flashes.html.erb'
run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/views/shared/_footer.html.erb > app/views/shared/_footer.html.erb'
run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/views/shared/_navbar.html.erb > app/views/shared/_navbar.html.erb'
run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/views/shared/_dropdown.html.erb > app/views/shared/_dropdown.html.erb'


HTML
# README
########################################
markdown_file_content = <<-MARKDOWN
Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file 'README.md', markdown_file_content, force: true

# Generators
########################################
generators = <<-RUBY
config.generators do |generate|
      generate.assets false
      generate.helper false
    end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rake 'db:drop db:create db:migrate'
  generate('simple_form:install', '--bootstrap')
  generate(:controller, 'pages', 'home', '--skip-routes')

  run 'spring binstub --all'

  # Guard initialize
  ########################################
  run 'guard init'

  inject_into_file 'config/spring.rb', before: ').each { |path| Spring.watch(path) }' do
  '  config/application.yml\n'
  end

  # RSPEC
  ########################################
  generate('rspec:install')
  run 'mkdir spec/factories'

  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/spec/spec_helper.rb > spec/spec_helper.rb'
  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/spec/factories_spec.rb > spec/factories_spec.rb'
  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/spec/factories/user.rb > spec/factories/user.rb'


  # Routes
  ########################################
  route "root to: 'pages#home'"

  # Git ignore
  ########################################
  run 'rm .gitignore'
  file '.gitignore', <<-TXT
    .bundle
    log/*.log
    tmp/**/*
    tmp/*
    *.swp
    .DS_Store
    public/assets
  TXT

  # Annotate
  ########################################
  generate('annotate:install')

  # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    layout :layout_by_resource
    private
    def layout_by_resource
      if devise_controller? && action_name != "edit"
        "authentication"
      else
        "application"
      end
    end
  end
  RUBY

  # migrate + devise views
  ########################################
  rake 'db:migrate'
  generate('devise:views')

  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/devise-views/new_session.html.erb > app/views/devise/sessions/new.html.erb'
  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/devise-views/new_registration.html.erb > app/views/devise/registrations/new.html.erb'
  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/devise-views/edit_registration.html.erb > app/views/devise/registrations/edit.html.erb'
  run 'curl -L https://raw.githubusercontent.com/adrienpoly/rails-templates/master/devise-views/new_password.html.erb > app/views/devise/passwords/new.html.erb'


  # Pages Controller
  ########################################
  run 'rm app/controllers/pages_controller.rb'
  file 'app/controllers/pages_controller.rb', <<-RUBY
  class PagesController < ApplicationController
    skip_before_action :authenticate_user!, only: [:home]

    def home
    end
  end
  RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

  # Figaro
  ########################################
  run 'bundle binstubs figaro'
  run 'figaro install'

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with devise template from https://github.com/lewagon/rails-templates'"
end
