# Clog

CoffeeScript static analysis for code quality metrics. Inspired by flog for Ruby. Runs as a CLI, generating a report describing churn and complexity of each file or directory passed to it.

## Installation

`npm install -g clog-analysis`

## Usage

`clog path/to/file1.coffee path/to/file2.coffee my/dir`

Generates a report of churn and complexity for `file1.coffee`, `file2.coffee`, and all `.coffee`, `.coffee.md`, and `.litcoffee` files inside `my/dir` or any of its subdirectories.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request