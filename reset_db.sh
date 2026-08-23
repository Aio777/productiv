#!/bin/bash

# Reset Rails database and start servers

# Remove schema file
rm db/schema.rb

# Restart PostgreSQL service
sudo service postgresql stop
sudo service postgresql start

# Reset and migrate database
rails db:reset
rails db:migrate
rails db:reset

