class TagsController < ApplicationController
  before_action :login_only
  before_action :_tag_control_privilege_check, only: [:create, :delete]
  before_action :_find_tag, only: [:delete]

  private

  def _tag_control_privilege_check
    _current_user = current_user
    unless _current_user.is_admin?
      render json: response_json(
        false,
        message: nil
      )
      false
    end
  end

  def _find_tag
    _tag = Tag.find_by(tag_name: params[:tagName])
    unless _tag
      render json: response_json(
        false,
        message: nil
      )
      false
    end

    @tag = _tag
  end

  public

  def show
    render status: 200, json: response_json(
      true,
      data: {
        tags: Tag.all.collect do|tag|
          {
            tagName: tag.tag_name,
            references: tag.reference_number
          }
        end
      }
    )
  end

  def create
    if Tag.find_by(tag_name: params[:tagName])
      render json: response_json(
        false,
        message: nil
      )
    end

    _tag = Tag.new tag_name: params[:tagName]
    _tag.reference_number = 0
    if _tag.save
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

  def delete
    _tag = @tag
    if _tag.destroy
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
    @tag = nil
  end

end
