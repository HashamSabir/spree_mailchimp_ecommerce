# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class DeletePromoRuleJob < ApplicationJob
    def perform(mailchimp_promo_rule)
      gibbon_store(mailchimp_promo_rule["store_id"]).promo_rules(mailchimp_promo_rule["id"]).delete
    end
  end
end
