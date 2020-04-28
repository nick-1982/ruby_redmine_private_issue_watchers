require_dependency 'issue'

module Patches
  module Access
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :visible?, :watch
        class << self
        end
      end
    end

    module InstanceMethods
      def visible_with_watch?(usr=nil)
        (usr || User.current).allowed_to?(:view_issues, self.project) do |role, user|
          visible = if user.logged?
          case role.issues_visibility
          when 'all'
            true
          when 'default'
            !self.is_private? || (self.author == user || self.watched_by?(user) || user.is_or_belongs_to?(assigned_to))
          when 'own'
            !self.is_private? || (self.author == user || self.watched_by?(user) || user.is_or_belongs_to?(assigned_to))
           else
             false
           end
         else
           !self.is_private?
         end
         unless role.permissions_all_trackers?(:view_issues)
           visible &&= role.permissions_tracker_ids?(:view_issues, tracker_id)
         end
         visible
       end
     end
   end
 end
end
