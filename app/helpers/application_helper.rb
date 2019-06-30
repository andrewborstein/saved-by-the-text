module ApplicationHelper
  def body_classes(classes=nil)
    ary = [Rails.application.class.to_s.split("::").first.downcase]
    ary << controller.controller_name
    ary << controller.action_name
    ary << 'mobile' if mobile_agent?

    unless classes.nil?
      method = classes.is_a?(Array) ? :concat : :<<
      ary.send method, classes
    end

    ary.join(' ')
  end

  def mobile_agent?
    return true if params[:mobile] == "1"
    request.user_agent =~ /Mobile|webOS/
  end
end
