class RepliesController < ApplicationController
  before_action :login_only

  public

  def show
    _self_received = Reply.all.filter(&->(_reply){ _reply.deliver_id == current_user.id })
    render status: 200, json: response_json(
      true,
      data: {
        unchecked: _self_received.filter(&:is_unchecked?).collect do |_reply|
          {
            id: _reply.id,
            username: _reply.reply_user.username,
            studentId: _reply.reply_user.student_id,
            postTitle: _reply.post.title
          }
        end,
        checked: _self_received.filter(&:is_checked?).collect do |_reply|
          {
            id: _reply.id,
            username: _reply.reply_user.username,
            studentId: _reply.reply_user.student_id,
            postTitle: _reply.post.title
          }
        end
      }
    )
  end

  def open
    _reply = Reply.find_by(id: params[:id])
    _reply.status = 1
    if _reply.save
      render status: 200, json: response_json(
        true,
        data: {
          content: _reply.content,
          postId: _reply.post_id,
          postTitle: _reply.post.title,
          postType: _reply.post.category
        }
      )
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end
end
