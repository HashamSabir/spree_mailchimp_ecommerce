class MailchimpSetting < ActiveRecord::Base
  validates :mailchimp_api_key, :mailchimp_store_id, :mailchimp_list_id, :mailchimp_store_name, :cart_url, presence: true
  validate :validate_only_one_store, on: :create

  belongs_to :store, class_name: "Spree::Store"

  def validate_only_one_store
    # errors.add(:base, "only one store allowed") unless MailchimpSetting.count.zero?
    errors.add(:base, "only one store allowed") if MailchimpSetting.where(store_id: self.store_id).present?
  end

  def already_exist?
    attrs = self.attributes.slice("mailchimp_api_key", "mailchimp_list_id", "mailchimp_store_name")
    other_settings = MailchimpSetting.where(attrs)
    other_settings = other_settings - [self]
    other_settings.any?
  end

  def create_store_id
    Digest::MD5.hexdigest(mailchimp_store_name + mailchimp_list_id).to_s
  end

  def accout_name
    ::SpreeMailchimpEcommerce::GetAccountNameJob.perform_now(self)
  end
end
