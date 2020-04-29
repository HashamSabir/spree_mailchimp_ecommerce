# frozen_string_literal: true

module SpreeMailchimpEcommerce
  class DeletePromoCodeJob < ApplicationJob
    def perform(mailchimp_promo_rule, mailchimp_promo_code)
      gibbon_store(mailchimp_promo_rule["store_id"]).promo_rules(mailchimp_promo_rule["id"]).
        promo_codes(mailchimp_promo_code["id"]).delete
    end
  end
end
