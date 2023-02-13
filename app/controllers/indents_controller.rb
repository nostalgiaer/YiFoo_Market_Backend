class IndentsController < ApplicationController
  before_action :login_only

  public

  def show
    render status: 200, json: response_json(
      true,
      data: {
        proceeding: current_user.indents.where(status: 1).collect do |_order|
          _commodity, _post = _order.commodity, _order.commodity.commodity_group.post
          {
            num: _order.num,
            name: _commodity.name,
            price: _commodity.price * _order.num,
            target: _post.author.username
          }
        end,
        finished: current_user.indents.where(status: 2).collect do |_order|
          _commodity, _post = _order.commodity, _order.commodity.commodity_group.post
          {
            num: _order.num,
            name: _commodity.name,
            price: _commodity.price * _order.num,
            target: _post.author.username
          }
        end
      }
    )
  end

end
