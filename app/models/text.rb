# frozen_string_literal: true

class Text < ActiveRecord::Base
  before_create :sanitize_num

  validates_presence_of :num,
                        message: "Phone number can't be blank. We're sending a text message, silly!"
  validates :num,
            format: { with: /\(?\d{3}[)]\s\d{3}[-]\d{4}/,
                      message: 'Phone number must be formatted like (123) 456-7890' }

  private

  def sanitize_num
    self.num = "***-***-#{num.slice(-4, 4)}"
  end
end
