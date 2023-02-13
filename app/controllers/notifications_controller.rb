class NotificationsController < ApplicationController
  before_action :login_only
  before_action :_find_notification, only: [:open, :confirm]

  private

  def _find_notification
    @notification = Notification.find_by(id: params[:id])
    unless @notification
      false
    end
  end

  public

  def show_purchase
    _user = current_user
    render status: 200, json: response_json(
      true,
      data: {
        unchecked: Notification.where(deliver_id: _user.id, status: 2).collect do |_unchecked|
          _sender, _order = _unchecked.sender, _unchecked.indent
          {
            id: _unchecked.id,
            postId: _unchecked.indent.commodity.commodity_group.post_id,
            postTitle: _unchecked.indent.commodity.commodity_group.post.title,
            category: _unchecked.direction,
            username: _sender.username,
            studentId: _sender.student_id,
            commodityId: _order.commodity_id,
            commodityName: _order.commodity.name,
            num: _order.num
          }
        end,
        checked: Notification.where(deliver_id: _user.id, status: 1).collect do |_checked|
          _sender, _order = _checked.sender, _checked.indent
          {
            id: _checked.id,
            postId: _checked.indent.commodity.commodity_group.post_id,
            postTitle: _checked.indent.commodity.commodity_group.post.title,
            category: _checked.direction,
            username: _sender.username,
            studentId: _sender.student_id,
            commodityId: _order.commodity_id,
            commodityName: _order.commodity.name,
            num: _order.num
          }
        end
      }
    )
  end

  def open
    _notification = @notification
    _post, _indent = _notification.indent.commodity.commodity_group.post, _notification.indent
    _notification.status = 1
    if _notification.save
      render status: 200, json: response_json(
        true,
        data: {
          content: _notification.content,
          category: _notification.direction,
          postId: _post.id,
          postTitle: _post.title,
          postType: _post.category,
          commodityId: _indent.commodity.id,
          commodityName: _indent.commodity.name,
          number: _indent.num
        }
      )
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def confirm
    _notification = Notification.new status: 3, direction: 2, content: "ok"
    _notification.indent_id = @notification.indent_id
    _notification.user_id = current_user.id
    _notification.deliver_id = @notification.user_id
    @notification.status = 1
    @notification.save
    _indent = Indent.where(id: @notification.indent_id).first
    _indent.status = 2
    _indent.save
    if _notification.save
      render status: 200, json: response_json(
        true,
        message: nil
      )
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def unchecked
    _unchecked_notifications = Notification.where(deliver_id: current_user.id, status: 2)
    _unchecked_replies = Reply.all.filter(&->(_reply){ _reply.deliver_id == current_user.id })
                              .filter(&:is_unchecked?)
    _have_unchecked = !(_unchecked_replies.empty? && _unchecked_notifications.empty?)
    render status: 200, json: response_json(
      true,
      message: nil,
      data: {
        hasEmails: _have_unchecked
      }
    )
  end

end
