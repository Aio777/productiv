# frozen_string_literal: true

class Subscriber::ItemShopController < Subscriber::BaseController
  before_action :load_shop_items, only: %i[index create]
  before_action :set_item, only: %i[show]
  before_action :create_subscriber_poro, only: %i[create]
  before_action :redirect_non_frame_requests!, only: %i[show]

  def index; end

  def show; end

  def create
    @user_item = UserItem.new(user_item_params)

    if @current_user.points < @user_item.item.price
      turbo_response(:alert, 'You do not have enough points to purchase this item.')
    elsif @user_item.save
      @subscriber_poro.purchase_item(@user_item.item)
      Metrics::MetricTrackerService.new(ahoy).track_shop_purchase(@current_user.id, @user_item.item_id, request)

      @user_items = @subscriber_poro.set_user_items
      turbo_response(:notice, 'Item has been successfully purchased!')
    else
      redirect_to subscriber_items_path, status: :unprocessable_content,
                                         alert: @user_item.errors.full_messages.to_sentence
    end
  end

  private

  def load_shop_items
    @plant_items = Item.where(category: 'plant').where('name LIKE ?', '% Seed').where.not("name = 'Daisy Seed'")
    @pot_items = Item.where(category: 'pot').where.not("name = 'Square Pot'")
  end

  def set_item
    @item = Item.find(params.expect(:id))
  end

  def redirect_non_frame_requests!
    redirect_to subscriber_items_path unless turbo_frame_request?
  end

  def turbo_response(flash_type, message)
    @item = @user_item.item

    respond_to do |format|
      format.turbo_stream { flash[flash_type] = message }
      format.html { redirect_to subscriber_items_path }
    end
  end

  def create_subscriber_poro
    @subscriber_poro = Poro::Subscriber.new(current_user)
  end

  def user_item_params
    params.expect(user_item: [:item_id]).merge(user_id: @current_user.id)
  end
end
