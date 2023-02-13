class CommentsController < ApplicationController
  before_action :login_only
  before_action :_find_post, only: %i[show create create_post_comment create_inner_comment_reply]
  before_action :_find_comment, only: %i[create_inner_comment create_inner_comment_reply]

  private

  def _can_current_user_control?(_comment)
    _user = current_user
    _user.is_admin? or _comment.reviewer.id == _user.id
  end

  def _find_post
    @post = Post.find_by(id: params[:postId])
  end

  def _find_comment
    @comment = Comment.where(id: params[:commentId]).first
  end

  def _cascade_delete_inner_comment(_inner_comment)
    _to_delete_comments = [_inner_comment]
    until _to_delete_comments.empty?
      _comment = _to_delete_comments.pop
      InnerComment.where(reply_comment_id: _comment.id, reply_object_type: 2)
                  .collect(&_to_delete_comments.method(:push))
      return false unless _comment.destroy
    end
    true
  end

  public

  def show
    render status: 200, json: response_json(
      true,
      message: nil,
      data: {
        comments: @post.comments.collect do |_comment|
          _author = _comment.reviewer
          _image_relative_path = "/users/#{_author.id}.png"
          _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + _image_relative_path
          _author_avatar = "http://localhost:#{PORT}/users/#{_author.id}.png" if File.exist? _image_path
          {
            id: _comment.id,
            authorName: _author.username,
            authorRole: _author.user_role,
            authorId: _author.student_id,
            commentTime: _comment.created_at,
            content: _comment.content,
            avatar: _author_avatar,
            likes: _comment.likes,
            unlikes: _comment.hates,
            children: _comment.inner_comments.collect do |_inner_comment|
              _user = _inner_comment.reviewer
              _image_relative_path = "/users/#{_user.id}.png"
              _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + _image_relative_path
              _avatar = "http://localhost:#{PORT}/users/#{_user.id}.png" if File.exist?_image_path
              _reply_comment = InnerComment.find_by(id: _inner_comment.reply_comment_id) if _inner_comment.reply_inner_comment?
              _reply_comment ||= _inner_comment.comment if _inner_comment.reply_outer_comment?
              {
                id: _inner_comment.id,
                targetName: _reply_comment.reviewer.username,
                targetRole: _reply_comment.reviewer.user_role,
                authorName: _user.username,
                authorRole: _user.user_role,
                authorId: _user.student_id,
                commentTime: _inner_comment.created_at,
                content: _inner_comment.content,
                likes: _inner_comment.likes,
                unlikes: _inner_comment.hates,
                avatar: _avatar
              }
            end
          }
        end
      }
    )
  end

  def create_post_comment
    _post, _user = @post, current_user
    _comment = _post.comments.new content: params[:content], user_id: _user.id
    if _comment.save
      _content = "User #{current_user.username} review your post #{_post.id}."
      _reply = _post.replies.new status: 2, content: _content
      _reply.user_id, _reply.deliver_id = _user.id, _post.user_id
      if _reply.save
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
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def create_inner_comment
    _comment, _user = @comment, current_user
    _inner_comment = _comment.inner_comments.new content: params[:content], user_id: _user.id
    _inner_comment.reply_object_type = 1
    if _inner_comment.save
      _content = "User #{current_user.username} review on your comment."
      _reply = Reply.new status: 2, content: _content, user_id: _user.id
      _reply.post_id, _reply.deliver_id = _comment.post_id, _comment.user_id
      if _reply.save
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
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def create_inner_comment_reply
    _comment, _user = @comment, current_user
    _inner_comment = _comment.inner_comments.new content: params[:content], user_id: _user.id
    _inner_comment.reply_comment_id = params[:replyCommentId]
    _inner_comment.reply_object_type = 2
    _target_comment = InnerComment.where(id: params[:replyCommentId]).first
    if _inner_comment.save
      _content = "User #{current_user.username} review your comment."
      _reply = Reply.new status: 2, content: _content, user_id: _user.id
      _reply.post_id, _reply.deliver_id = _comment.post_id, _target_comment.user_id
      if _reply.save
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
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def delete
    if params[:commentType].to_i == 2
      _inner_comment = InnerComment.where(id: params[:commentId]).first
      unless _can_current_user_control? _inner_comment
        render json: response_json(
          false,
          message: nil
        ) and return
      end

      if _cascade_delete_inner_comment _inner_comment
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
    else
      _comment = Comment.where(id: params[:commentId]).first
      unless _can_current_user_control? _comment
        render json: response_json(
          false,
          message: nil
        ) and return
      end

      if _comment.destroy
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
  end

  def like
    if params[:commentType].to_i == 1
      _comment = Comment.find_by(id: params[:commentId].to_i)
    else
      _comment = InnerComment.find_by(id: params[:commentId].to_i)
    end
    if params[:likes].to_i == 1
      _comment.likes = _comment.likes + 1
    else
      _comment.hates = _comment.hates + 1
    end
    _comment.save
    render status: 200, json: response_json(
      true,
      message: nil
    )
  end
end
