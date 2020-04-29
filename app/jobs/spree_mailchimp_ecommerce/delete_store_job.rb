module SpreeMailchimpEcommerce
  class DeleteStoreJob < ApplicationJob
    def perform(spree_store_hash)
      begin
        gibbon_store(spree_store_hash["store_id"]).delete
      rescue Gibbon::MailChimpError => e
        Rails.logger.warn "[MAILCHIMP] Failed to delete store. #{e}"
      end
    end
  end
end
