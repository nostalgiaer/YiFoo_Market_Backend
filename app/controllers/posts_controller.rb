class PostsController < ApplicationController
  before_action :login_only
  before_action :_find_post, except: [:show, :create_sell, :create_buy, :update_buy_post_image,
                                      :update_commodity_images, :search, :test]
  before_action :_post_control_privilege_check, only: [:close, :modify, :delete_commodity,
                                                       :create_commodity, :modify_remain]
  before_action :_find_tag, only: [:add_tag, :delete_tag]
  before_action :_find_commodity_group, only: [:delete_commodity, :modify_remain]


  private

  def _find_post
    @post = Post.find_by(id: params[:postId])
    unless @post
      render json: response_json(
        false,
        message: PostOperationError::POST_NOT_EXISTED
      )
      false
    end
  end

  def _post_control_privilege_check
    unless @post.author.id == current_user.id or current_user.is_admin?
      render json: response_json(
        false,
        message: PostOperationError::POST_ACCESS_DENIED
      )
      false
    end
  end

  def _get_show_start_index(_page, _page_size)
    (_page.to_i - 1) * _page_size.to_i
  end

  def _post_params
    params.require(:post).permit(:title, :content)
  end

  def _find_tag
    @tag = Tag.find_by(tag_name: params[:tagName])
    unless @tag
      render json: response_json(
        false,
        message: nil
      )
      false
    end
  end

  def _find_commodity_group
    @commodity_group = CommodityGroup.where(id: params[:groupId]).first
    unless @commodity_group
      render json: response_json(
        false,
        message: nil
      )
      false
    end
  end

  public

  def show
    _type = params[:type] == 'buy' ? 1: 2
    _length = Post.where(category: _type).length
    _page_size = params[:pageSize]
    _start = _get_show_start_index params[:curPage], params[:pageSize]
    if params[:tags].nil?
      render status: 200, json: response_json(
        true,
        data: {
          posts: Post.where(category: _type).limit(_page_size)
                     .offset(_start).collect do |post|
            _author, _favorite = post.author, 0
            if post.is_buy_post?
              image_url = "http://localhost:#{PORT}/buy_posts/#{post.id}.png"
            else
              _first_commodity = post.commodities.first
              image_url = "http://localhost:#{PORT}/commodities/#{_first_commodity.id}.png" unless _first_commodity.nil?
            end
            _favorite = 1 if current_user.follow_infos.exists?(post_id: post.id)
            {
              postId: post.id,
              title: post.title,
              description: "",
              username: _author.username,
              favorite: _favorite,
              heat: post.heat,
              postUserId: _author.id.to_s,
              img: image_url,
              tags: post.tags.collect do |_tag|
                {
                  tagName: _tag.tag_name
                }
              end
            }
          end,
          totalCnt: _length
        }
      )
    else
      _posts = []
      Tag.where(tag_name: params[:tags]).collect do|_tag|
        _tag.posts.map(&->(_post) { _post.id }).collect(&_posts.method(:push))
      end
      _posts.uniq!
      render status: 200, json: response_json(
        true,
        data: {
          posts: Post.where(category: _type, id: _posts).limit(_page_size)
              .offset(_start).collect do |post|
            _author, _favorite = post.author, 0
            if post.is_buy_post?
              image_url = "http://localhost:#{PORT}/buy_posts/#{post.id}.png"
            else
              _first_commodity = post.commodities.first
              image_url = "http://localhost:#{PORT}/commodities/#{_first_commodity.id}.png" unless _first_commodity.nil?
            end
            _favorite = 1 if current_user.follow_infos.exists?(post_id: post.id)
            {
              postId: post.id,
              title: post.title,
              description: "",
              username: _author.username,
              favorite: _favorite,
              heat: post.heat,
              postUserId: _author.student_id.to_s,
              img: image_url,
              tags: post.tags.collect do |_tag|
                {
                  tagName: _tag.tag_name
                }
              end
            }
          end,
          totalCnt: _posts.length
        }
      )
    end
  end

  def search
    render status: 200, json: response_json(
      true,
      data: {
        posts: Post.where(category: params[:type].to_i)
                   .where("title LIKE :content", { content: ['%', params[:title].to_s, '%'].join })
                   .collect do |post|
          _author, _favorite = post.author, 0
          if post.is_buy_post?
            image_url = "http://localhost:#{PORT}/buy_posts/#{post.id}.png"
          else
            _first_commodity = post.commodities.first
            image_url = "http://localhost:#{PORT}/commodities/#{_first_commodity.id}.png"
          end
          _favorite = 1 if current_user.follow_infos.exists?(post_id: post.id)
          {
            postId: post.id,
            title: post.title,
            description: "",
            username: _author.username,
            favorite: _favorite,
            heat: post.heat,
            postUserId: _author.id,
            img: image_url,
            tags: post.tags.collect do |_tag|
              {
                tagName: _tag.tag_name
              }
            end
          }
        end
      }
    )
  end

  def create_buy
    _post = Post.new title: params[:title], content: params[:content]
    _post.author = current_user
    _post.category, _post.heat = 1, 0

    if _post.save
      render status: 200, json: response_json(
        true,
        message: PostOperationError::POST_OPERATION_SUCCESS,
        data: {
          postId: _post.id
        }
      )

      unless params[:tags].nil?
        params[:tags].collect do |_tag_name|
          _tag = Tag.where(tag_name: _tag_name).first
          unless _tag
            render json: response_json(
              false,
              message: nil
            ) and return
          end
          _post.tags << _tag
        end
      end

    else
      render json: response_json(
        false,
        message: PostOperationError::POST_CREATE_FAIL
      )
    end
  end

  def create_sell
    _post = Post.new title: params[:title], content: params[:content]
    _post.user_id = current_user.id
    _post.category, _post.heat = 2, 0
    _commodity_set = Array.new

    unless _post.save
      render json: response_json(
        false,
        message: PostOperationError::POST_CREATE_FAIL
      )
    end
    unless params[:tags].nil?
      params[:tags].collect do |_tag_name|
        _tag = Tag.find_by(tag_name: _tag_name)
        puts _tag_name
        unless _tag
          render json: response_json(
            false,
            message: nil
          ) and return
        end
        _post.tags << _tag
      end
    end

    params[:goods].collect do |_good_info|
      puts _good_info[:name]
      _commodity_group = CommodityGroup.new post_id: _post.id, number: _good_info[:num].to_i
      unless _commodity_group.save
        render json: response_json(
          false,
          message: nil
        ) and return
      end
      _commodity = Commodity.new name: _good_info[:name], price: _good_info[:price].to_i, description: _good_info[:description]
      _commodity.commodity_group_id = _commodity_group.id
      _commodity.save
      _commodity_set << _commodity.id
    end

    render status: 200, json: response_json(
      true,
      data: {
        commodityIds: _commodity_set
      }
    )
  end

  def open
    _author, _post = @post.author, @post
    _image_url = "http://localhost:#{PORT}/buy_posts/#{_post.id}.png"
    render status: 200, json: response_json(
      true,
      data: {
        title: _post.title,
        content: _post.content,
        username: _author.username,
        postImg: _image_url,
        postOwnerId: _author.student_id
      }
    )
  end

  def close
    _post = @post
    if _post.destroy
      render status: 200, json: response_json(
        true,
        message: PostOperationError::POST_OPERATION_SUCCESS
      )
    else
      render json: response_json(
        false,
        message: PostOperationError::POST_DELETE_FAIL
      )
    end
    @post = nil
  end

  def modify
    _post = @post
    if _post.update(_post_params)
      render status: 200, json: response_json(
        true,
        message: PostOperationError::POST_OPERATION_SUCCESS
      )
    else
      render json: response_json(
        false,
        message: PostOperationError::POST_UPDATE_FAIL
      )
    end
  end

  def acquire_available_tags
    _post = @post
    render status: 200, json: response_json(
      true,
      data:
        {
          unUsedTags: Tag.where.not(tag_name: _post.tags.map(&:tag_name)).collect do |_tag|
          {
            tagName: _tag.tag_name,
            references: _tag.reference_number
          }
          end,
          usedTags: Tag.where(tag_name: _post.tags.map(&:tag_name)).collect do |_tag|
            {
              tagName: _tag.tag_name,
              references: _tag.reference_number
            }
          end
        }
    )
  end

  def add_tag
    _tag, _post = @tag, @post
    if _post.tags.exists?(tag_name: _tag.tag_name)
      render json: response_json(
        false,
        message: nil,
        data: {
          tags: _post.tags.collect do |_tag|
            {
              tagName: _tag.tag_name
            }
          end
        }
      )
    else
      _post.tags << _tag
      render status: 200, json: response_json(
        true,
        message: nil
      )
    end
  end

  def delete_tag
    _tag, _post = @tag, @post
    if _post.tags.delete(_tag)
      render status: 200, json: response_json(
        true,
        message: nil,
        data: {
          tags: _post.tags.collect do |_tag|
            {
              tagName: _tag.tag_name
            }
          end
        }
      )
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def follow
    _post, _user = @post, current_user
    _post.heat += 2
    unless _post.save
      render json: response_json(
        false,
        message: nil
      ) and return
    end
    if _post.author.id == _user.id
      render json: response_json(
        false,
        message: "nonono"
      )
    else
      if _post.follow_infos.exists?(user_id: _user.id)
        render json: response_json(
          false,
          message: nil
        ) and return
      end
      _follow_info = _post.follow_infos.new user_id: _user.id, annotation: params[:annotation]
      if _follow_info.save
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

  def non_follow
    if @post.author.id == current_user.id
      render json: response_json(
        false,
        message: nil
      )
    else
      _follow = @post.follow_infos.find_by(user_id: current_user.id)
      if _follow
        if _follow.destroy
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
  end

  def commodities
    render status: 200, json: response_json(
      true,
      data: {
        goods: @post.commodity_groups.collect do |_commodity_group|
          _commodity = _commodity_group.commodity
          {
            groupId: _commodity_group.id,
            commodityId: _commodity.id,
            name: _commodity.name,
            num: _commodity_group.number,
            description: _commodity.description,
            price: _commodity.price,
            img: "http://localhost:#{PORT}/commodities/#{_commodity.id}.png"
          }
        end
      }
    )
  end

  def modify_remain
    _commodity_group = @commodity_group
    _commodity_group.number = params[:num]
    if _commodity_group.save
      render status: 200, json: response_json(
        true,
        message: Global::SUCCESS
      )
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def create_commodity
    _commodity_group = @post.commodity_groups.new number: params[:num].to_i
    unless _commodity_group.save
      render json: response_json(
        false,
        message: nil
      )
    end
    _commodity = Commodity.new name: params[:name], description: params[:description], price: params[:price]
    _commodity.commodity_group_id = _commodity_group.id

    if _commodity.save
      render status: 200, json: response_json(
        true,
        message: Global::SUCCESS,
        data: {
          commodityId: _commodity.id
        }
      )
    else
      render json: response_json(
        false,
        message: nil
      )
    end
  end

  def update_buy_post_image
    _post_id = params[:postId].to_i
    _image_relative_path = "/#{_post_id}.png"
    _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + "/buy_posts"
    unless File::exist? _image_path
      Dir::mkdir _image_path
    end
    _image_path = _image_path + +_image_relative_path
    _image = File.open(params[:img].path, 'rb')
    File.new(_image_path, "w+")
    _local_image = File.open(_image_path, 'wb') << _image.read
    _image.close

    render status: 200, json: response_json(
      true,
      message: nil
    )
  end

  def update_commodity_images
    _commodity_id = params[:commodityId].to_i

    _commodity = Commodity.where(id: _commodity_id).first
    _post = _commodity.commodity_group.post
    _image_relative_path = "/commodities/#{_commodity_id}.png"
    _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + _image_relative_path

    _image = File.open(params[:img].path, 'rb')
    File.new(_image_path, "w+")
    _local_image = File.open(_image_path, 'wb') << _image.read
    _image.close

    render status: 200, json: response_json(
      true,
      message: nil
    )
  end

  def delete_commodity
    _commodity_group = @commodity_group
    if _commodity_group.destroy
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
    @commodity_group = nil
  end

  def purchase
    _goods = params[:goods]
    unless _goods.select do |_good_info|
      CommodityGroup.find_by(id: _good_info[:groupId]).number < _good_info[:num].to_i
    end.empty?
      render json: response_json(
        false,
        message: nil
      )
    end

    _goods.collect do |_good|
      _commodity_group = CommodityGroup.where(id: _good[:groupId]).first
      _remain = _commodity_group.number - _good[:num].to_i
      if _remain <= 0
        unless _commodity_group.destroy
          render json: response_json(
            false,
            message: nil
          ) and return
        end
      else
        _commodity_group.number = _remain
      end

      unless _commodity_group.save
        render json: response_json(
          false,
          message: nil
        ) and return
      end

      _commodity = _commodity_group.commodity
      _order = _commodity.indents.new status: 1, num: _good[:num].to_i
      _order.user_id = current_user.id
      unless _order.save
        render json: response_json(
          false,
          message: nil
        ) and return
      end

      _notification = _order.notifications.new status: 2, direction: 1, content: "compiler!"
      _notification.user_id = current_user.id
      _notification.deliver_id = @post.user_id
      unless _notification.save
        render json: response_json(
          false,
          message: nil
        ) and return
      end
    end

    render status: 200, json: response_json(
      true,
      message: Global::SUCCESS
    )
  end

  def trolley
    params[:goods].collect do |_good_info|
      _commodity = Commodity.where(id: _good_info[:commodityId]).first
      _trolley = _commodity.trolleys.new number: _good_info[:num]
      _trolley.user_id = current_user.id
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
  end

  def complaint
    _post = @post
    _post.heat = _post.heat - 1
    unless _post.save
      render json: response_json(
        false,
        message: nil
      ) and return
    end
    _complaint = @post.complaints.new content: params[:content], status: 1
    _complaint.user_id = current_user.id
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

  def test
    render status: 200, json: response_json(
      true,
      data: {
        follows: current_user.follow_infos.collect do |_follow_info|
          {
            user: _follow_info.user_id,
            post: _follow_info.post_id,
            content: _follow_info.annotation
          }
        end,
        iftrue: current_user.follow_infos.exists?(post_id: 2)
      }
    )
  end
end
