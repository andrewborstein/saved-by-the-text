# frozen_string_literal: true

require 'twilio-ruby'

class TextsController < ApplicationController
  before_action :set_text, only: %i[show edit update destroy]

  def index
    @texts = Text.all.limit(5).order(created_at: :desc)
  end

  def show; end

  def new
    @text = Text.new
  end

  def edit; end

  def create
    @text = Text.new(text_params)

    if @text.valid?
      send_sms
    else
      render :new
    end
  end

  def update
    if params[:text][:msg].present?
      confirm = "Nice job, Cassanova! Texting Kelly with <strong>#{params[:text][:msg]}</strong> really warmed her heart. Check #{params[:text][:num]} for a copy of what you wrote."
    else
      params[:text][:msg] = "Hey Kelly... you're all that and a bag of chips!"
      confirm = "Wow, so original. Check #{num} to view the text message you sent Kelly."
    end
    if @text.update(text_params)
      redirect_to @text, notice: confirm
    else
      render :edit
    end
  end

  def destroy
    @text.destroy
    redirect_to texts_url, notice: 'Text was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_text
    @text = Text.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def text_params
    params.require(:text).permit(:num, :msg)
  end

  def send_sms
    unless ENV['TWILIO_ACCOUNT_SID'].present? && ENV['TWILIO_AUTH_TOKEN'].present?
      flash.now[:alert] = 'Text messaging service not properly configured'
      render :new
      return
    end

    begin
      @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

      num = params[:text][:num]
      msg = params[:text][:msg]

      if msg.present?
        msg = msg
        confirm = "Nice job, Cassanova! Texting Kelly with <strong>#{msg}</strong> really warmed her heart. Check #{num} for a copy of what you wrote."
      else
        msg = "Hey Kelly... you're all that and a bag of chips!"
        confirm = "Wow, so original. Check #{num} to view the text message you sent Kelly."
      end

      @client.account.messages.create(
        body: msg,
        to: num,
        from: ENV['TWILIO_PHONE_NUMBER'],
        media_url: 'http://i.imgur.com/YyVzOZh.jpg'
      )
      redirect_to @text, notice: confirm

      @text.save
    rescue Twilio::REST::RequestError => e
      flash.now[:alert] = e
      render :new
    end
  end
end
