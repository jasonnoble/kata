require 'fileutils'
require 'ostruct'

module Kata
  module Setup
    class Base
      attr_accessor :kata_name
      attr_reader :repo_name

      def initialize(kata_name = 'kata')
        self.kata_name = kata_name
        self.repo_name = kata_name
      end

      def create_repo options
        # Setup from github configuration
        raise Exception, 'Git not installed' unless system 'which git > /dev/null'

        github = OpenStruct.new :url => 'http://github.com/api/v2/json/'

        github_user, shell_user = %x{git config --get github.user}.chomp, ENV['USER']

        github.user = github_user.empty? ? shell_user : github_user

        raise Exception, 'Unable to determine github user' if github.user.empty?

        #github.token = %x{git config --get github.token}.chomp

        #raise Exception, 'Unable to determine github api token' if github.token.empty?

        #user_string = "-u '#{github.user}/token:#{github.token}'"
        #repo_params = "-d 'name=#{repo_name}' -d 'description=code+kata+repo'"

        # Create the repo on github
        #if options.repo
        #  print 'Creating github repo...'
        #  raise SystemCallError, 'unable to use curl to create repo on github' unless system <<-EOF
        #    curl -s #{user_string} #{repo_params} #{github.url}repos/create 2>&1 > /dev/null;
        #  EOF
        #  puts 'complete'
        #end

        # publish to github

        #print 'creating files for repo and initializing...'

        cmd = "cd #{repo_name};"
        if options.repo
          cmd << "git init 2>&1 > /dev/null;"
          cmd << "git add README .rspec lib/ spec/ 2>&1 > /dev/null;"
        else
          cmd << "git add #{ENV['PWD']}/#{repo_name};"
        end
        cmd << "git commit -m 'starting kata' 2>&1 > /dev/null;"
        #cmd << "git remote add origin git@github.com:#{github.user}/#{repo_name}.git 2>&1 > /dev/null;" if options.repo
        #cmd << 'git push origin master 2> /dev/null'

        raise SystemCallError, 'unable to add files to github repo' unless system(cmd)

        puts 'done'
        puts "You can now change directories to #{repo_name} and take your kata"
      end

      def repo_name=(kata_name)
        @repo_name = "#{kata_name.gsub(/( |-)\1?/, '_')}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}".downcase
      end

      def build_tree(type = 'ruby')
        case type
        when 'ruby'
          Kata::Setup::Ruby.new(kata_name).build_tree
        end
      end
    end
  end
end
