# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class UpdatePromoRuleJob < ApplicationJob
    def perform(mailchimp_promo_rule)
      gibbon_store(mailchimp_promo_rule["store_id"]).promo_rules(mailchimp_promo_rule["id"]).
        update(body: mailchimp_promo_rule)
    end
  end
end
