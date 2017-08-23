require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
])

SimpleCov.add_group 'git-tag-version', 'git-tag-version$'
SimpleCov.add_filter '^((?!git-tag-version$).)*$' # Filter everything but poorman file.
