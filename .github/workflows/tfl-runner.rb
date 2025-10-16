name: TFL to Ruby Transpiler Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Ruby 3.3
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.3'
        bundler-cache: false # No Gemfile needed for this simple setup

    - name: Run TFL Runner Script
      run: ruby tfl_runner.rb
