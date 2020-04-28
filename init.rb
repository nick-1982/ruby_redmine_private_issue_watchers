require 'redmine'
require 'patches/access'
require 'patches/watch'
require_dependency 'issue'

Redmine::Plugin.register :iprivate do
  name 'Iprivate plugin'
  author 'Nick'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url ''
  author_url ''
end

#Rails.application.config.to_prepare do
#  Issue.send(:include, Patches::Access)
#  Issue.send(:include, Patches::Watch)
#end
