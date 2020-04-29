module SpreeMailchimpEcommerce
  class DeleteProductJob < ApplicationJob
    def perform(mailchimp_product)
      gibbon_store(mailchimp_product["store_id"]).products(mailchimp_product["id"]).delete
    end
  end
end
