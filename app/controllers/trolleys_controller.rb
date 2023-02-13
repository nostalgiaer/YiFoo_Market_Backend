class TrolleysController < ApplicationController
  before_action :login_only
  before_action :_find_trolley, except: [:show, :purchase, :delete, :modify]

  private

  def _find_trolley
    @trolley = Trolley.where(id: params[:trolleyId]).first
    unless @trolley
      render json: response_json(
        false,
        message: nil
      )
      false
    end
  end

  public

  def show
    _post_hash = current_user.trolleys.to_enum.with_object({}) { |_trolley, _hash|
      _post_id = _trolley.commodity.commodity_group.post_id
      unless _hash.has_key? _post_id
        _hash.store(_post_id, [])
      end
      _hash[_post_id].push(_trolley)
    }

    puts _post_hash

    render status: 200, json: response_json(
      true,
      data: {
        carts: _post_hash.keys.collect do |_post_id|
          _post = Post.find_by(id: _post_id)
          {
            postId: _post.id,
            postTitle: _post.title,
            goods: _post_hash[_post_id].collect do |_trolley|
              _commodity = _trolley.commodity
              {
                trolleyId: _trolley.id,
                name: _commodity.name,
                num: _trolley.number,
                price: _commodity.price,
                commodityId: _commodity.id,
                img: "http://localhost:#{PORT}/commodities/#{_commodity.id}.png"
              }
            end
          }
        end
      }
    )
  end

  def delete
    params[:goods].collect do |_trolley_info|
      _trolley = Trolley.find_by(id: _trolley_info[:trolleyId].to_i)
      _trolley.destroy
    end
    render status: 200, json: response_json(
      true,
      message: nil
    )
  end

  def modify
    _trolley = Trolley.find_by(id: params[:trolleyId].to_i)
    _trolley.number = params[:num].to_i
    if _trolley.save
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

  def purchase
    params[:goods].collect do |_trolley_info|
      _trolley = Trolley.find_by(id: _trolley_info[:trolleyId].to_i)
      # check whether the remain number satisfy the need
      _commodity_group = _trolley.commodity.commodity_group
      if _commodity_group.number < _trolley.number
        render json: response_json(
          false,
          message: nil
        ) and return
      end
      # create notification from current_user
      #   to trolley.commodity.commodity_group_post.author
      _order = Indent.new status: 1, num: _trolley.number
      _order.commodity_id = _commodity_group.commodity.id
      _order.user_id = current_user.id
      unless _order.save
        render json: response_json(
          false,
          message: nil
        )
      end

      _content = "User #{current_user.username} want to purchase your commodity#{_commodity_group.commodity.id}."
      _notification = _order.notifications.new status: 2, direction: 1, content: _content
      _notification.user_id = current_user.id
      _notification.deliver_id = _commodity_group.post.user_id
      unless _notification.save
        render json: response_json(
          false,
          message: nil
        )
      end

      _trolley.destroy
    end

    render status: 200, json: response_json(
      true,
      message: nil
    )
  end

end
