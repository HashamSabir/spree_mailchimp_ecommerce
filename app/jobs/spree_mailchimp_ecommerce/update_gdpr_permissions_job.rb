module SpreeMailchimpEcommerce
  class UpdateGdprPermissionsJob < ApplicationJob
    def perform(mailchimp_user)
      return unless mailchimp_user

      gdpr_permissions = (mailchimp_member(mailchimp_user).retrieve.body[:marketing_permissions] rescue nil)
      return unless gdpr_permissions

      gdpr_permissions.each{ |gdpr| gdpr[:enabled] = mailchimp_user["opt_in_status"] }
      mailchimp_member(mailchimp_user).update(body: { "marketing_permissions": gdpr_permissions })
    end
    
    def mailchimp_member mailchimp_user
      member(mailchimp_user["store_id"], mailchimp_user["id"])
    end
  end
end
