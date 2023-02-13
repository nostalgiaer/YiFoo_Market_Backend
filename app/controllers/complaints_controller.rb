class ComplaintsController < ApplicationController
  before_action :_complaints_control_privilege_check

  private

  def _complaints_control_privilege_check
    unless current_user.is_admin?
      false
    end
  end

  public

  def show
    render status: 200, json: response_json(
      true,
      data: {
        complaints: Complaint.where(status: 1).collect do |_complaint|
          _post = _complaint.post
          {
            complaintId: _complaint.id,
            sourceId: _complaint.user.username,
            target: _post.author.username,
            postTitle: _post.title,
            postId: _post.id,
            postType: _post.category,
            content: _complaint.content
          }
        end
      }
    )
  end

  def solve
    _complaint = Complaint.where(id: params[:complaintId]).first
    if _complaint.is_solved?
      render status: 200, json: response_json(
        false,
        message: nil
      )
    else
      _complaint.status = 2
      if _complaint.save
        render status: 200, json: response_json(
          true,
          message: nil
        )
      else
        render status: 200, json: response_json(
          false,
          message: nil
        )
      end
    end
  end
end
