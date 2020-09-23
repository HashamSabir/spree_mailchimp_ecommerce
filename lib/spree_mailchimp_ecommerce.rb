require "spree_core"
require "spree_extension"
require "spree_mailchimp_ecommerce/engine"
require "gibbon"
require "spree_mailchimp_ecommerce/gibbon_decorator"

module SpreeMailchimpEcommerce
  class << self
    def configuration(store_id)
      Configuration.new(store_id)
    end
  end

  class Configuration
    ATTR_LIST = [:mailchimp_api_key, :mailchimp_store_id, :mailchimp_list_id, :mailchimp_store_name, :cart_url]

    def initialize(store_id)
      @store = ::Spree::Store.find_by_id(store_id)
    end

    ATTR_LIST.each do |a|
      define_method a do
        setting_model.try(a)
      end
    end

    private

    def setting_model
      return @store.mailchimp_setting if @store.present?
      ::MailchimpSetting.where(store_id: nil).last
    end
  end
end
