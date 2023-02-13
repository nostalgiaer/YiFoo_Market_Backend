class BroadcastsController < ApplicationController
  before_action :login_only
  before_action :_find_broadcast, only: %i[delete modify]
  before_action :_broadcast_control_privilege_check, only: %i[delete modify create]

  private

  def _find_broadcast
    @broadcast = Broadcast.find_by(id: params[:broadcastId])
    unless @broadcast
      render status: 400, json: response_json(
        false,
        message: nil
      )
      false
    end
  end

  def _broadcast_control_privilege_check
    if current_user.is_admin?
      true
    else
      false
    end
  end

  public

  def show
    render status: 200, json: response_json(
      true,
      data: {
        broadcasts: Broadcast.all.collect do |_broadcast|
          {
            title: _broadcast.title,
            context: _broadcast.content,
            postTime: _broadcast.created_at,
            broadcastId: _broadcast.id
          }
        end
      }
    )
  end

  def modify
    _broadcast = @broadcast
    _broadcast.title, _broadcast.content = params[:title], params[:content]
    if _broadcast.save
      render status: 200, json: response_json(
        true,
        message: nil
      )
    else
      render status: 400, json: response_json(
        false,
        message: nil
      )
    end
  end

  def delete
    _broadcast = @broadcast
    if _broadcast.destroy
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

  def create
    _broadcast = current_user.broadcasts.new title: params[:title], content: params[:content]
    if _broadcast.save
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
