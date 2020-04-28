require_dependency 'issue'

module Patches
  module Watch
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        class << self
          alias_method_chain :visible_condition, :watchers
        end
      end
    end

     module ClassMethods
       def visible_condition_with_watchers(user, options={})
         Project.allowed_to_condition(user, :view_issues, options) do |role, user|
         if [ 'default', 'own' ].include?(role.issues_visibility)
           user_ids = [user.id] + user.groups.map(&:id).compact
           watched_issues = Issue.watched_by(user).map(&:id)
           watched_issues_clause = watched_issues.empty? ? "" : " OR #{table_name}.id IN (#{watched_issues.join(',')})"
         end
         sql = if user.id && user.logged?
           case role.issues_visibility
           when 'all'
             nil
           when 'default'
             "(#{table_name}.is_private = #{connection.quoted_false} OR #{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}) #{watched_issues_clause})"
           when 'own'
             "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}) #{watched_issues_clause})"
           else
             '1=0'
           end
         else
           "(#{table_name}.is_private = #{connection.quoted_false})"
         end
         unless role.permissions_all_trackers?(:view_issues)
           tracker_ids = role.permissions_tracker_ids(:view_issues)
           if tracker_ids.any?
             sql = "(#{sql} AND #{table_name}.tracker_id IN (#{tracker_ids.join(',')}))"
           else
             sql = '1=0'
           end
         end
         sql
       end
     end
   end
 end
end
