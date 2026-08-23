# frozen_string_literal: true

class Subscriber::PlantsController < Subscriber::BaseController
  before_action :set_plant, only: %i[update]
  before_action :create_plant_poro

  def update
    respond_to do |format|
      current_plant_stage_index = @plant_poro.plant_stage_index

      if @plant.update(plant_params)
        @plant_poro.update_plant_image(current_plant_stage_index)

        format.turbo_stream {}
        format.html { redirect_to subscriber_root_path }
      else
        format.turbo_stream { render :edit, status: :unprocessable_content }
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def water
    @subscriber_poro = Poro::Subscriber.new(current_user)

    if @subscriber_poro.can_afford_to_water_plant?
      plant_stage_index = @plant_poro.plant_stage_index

      if plant_stage_index.zero?
        Metrics::MetricTrackerService.new(ahoy)
                                     .track_plant_brought_to_life(@plant_poro.plant.id, current_user.id, request)
      elsif plant_stage_index == 4
        Metrics::MetricTrackerService.new(ahoy)
                                     .track_plant_revived_from_death(@plant_poro.plant.id, current_user.id, request)
      end

      @plant_poro.water
      @subscriber_poro.pay_to_water_plant

      redirect_to_current_page(:notice, 'Plant has been successfully watered!')
    else
      redirect_to_current_page(:alert, 'You have insufficient points.')
    end
  end

  private

  def create_plant_poro
    @plant_poro = Poro::Plant.new(current_user.plant)
  end

  def redirect_to_current_page(flash_type, message)
    respond_to do |format|
      format.turbo_stream { redirect_to request.referer, flash: { flash_type => message } }
      format.html { redirect_to request.referer }
    end
  end

  def set_plant
    @plant = current_user.plant
  end

  def plant_params
    params.expect(plant: %i[plant_type_id pot_type_id])
  end
end
