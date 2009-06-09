module Healing
  module Structure
    class GitRepo < Repo

      def initialize parent, path, options={}
        super parent, path, options

        before do
          package 'git-core'
        end

      end

      def heal
        super
        run "git clone --depth 1 #{url} #{path}"
        if user && group
          run "chown #{user}:#{group} #{path} -R"
        elsif user
          run "chown #{user} #{path} -R"
        end
      end
      
      def describe_name
        puts_title :git_repo, path
      end
      
      def describe_settings
        puts_setting :url if url
      end


    end
  end
end