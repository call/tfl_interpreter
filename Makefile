.PHONY: test

test:
	bundle exec ruby -Ilib:test test/test_all.rb
