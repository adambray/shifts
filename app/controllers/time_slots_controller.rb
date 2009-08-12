class TimeSlotsController < ApplicationController
  before_filter :require_department_admin
  layout 'shifts'

  def index
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @block_length = current_department.department_config.time_increment
    @blocks_per_hour = 60/@block_length.to_f
    @blocks_per_day = @hours_per_day * @blocks_per_hour
    @hidden_timeslots = [] #for timeslots that don't show up on the view
  end

  def show
    @time_slot = TimeSlot.find(params[:id])
  end

  def new
    @time_slot = TimeSlot.new
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
  end

  def create
    @time_slots = []
    errors = []
    date = (params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday).to_time
    for location_id in params[:location_ids]
      for day in params[:days]
        time_slot = TimeSlot.new(params[:time_slot])
        time_slot.location_id = location_id
        time_slot.start = date + day.to_i.days + time_slot.start.seconds_since_midnight
        time_slot.end = date + day.to_i.days + time_slot.end.seconds_since_midnight
        time_slot.calendar = @department.calendars.default.first unless time_slot.calendar
        if !time_slot.save
          errors << "Error saving timeslot for #{WEEK_DAYS[day]}"
        else
          @time_slots << time_slot
        end
      end
    end
    respond_to do |format|
      format.html do
        if errors.empty?
          flash[:notice] = "Successfully created timeslot(s)."
        else
          flash[:error] =  "Error: "+errors*"<br/>"
        end
        redirect_to time_slots_path
      end
      format.js do
        if errors.empty?
          @dept_start_hour = current_department.department_config.schedule_start / 60
          @dept_end_hour = current_department.department_config.schedule_end / 60
          @hours_per_day = (@dept_end_hour - @dept_start_hour)
        else
          render :update do |page|
            ajax_alert(page, "<strong>error:</strong> timeslot could not be saved<br>"+errors)
          end
        end
      end
    end
  end

  def edit
    @time_slot = TimeSlot.find(params[:id])
  end

  def update
    @time_slot = TimeSlot.find(params[:id])

    # from AJAX edit view
    # if start time is pushed forward beyond end time, preserve duration
    if params[:wants] == 'start'
      new_start = Time.parse(params[:time_slot][:start])
      if new_start > @time_slot.end
        params[:time_slot][:end] = new_start + @time_slot.duration
      end
    elsif params[:wants] == 'end'
      new_end = Time.parse(params[:time_slot][:end])
      if new_end < @time_slot.start
        params[:time_slot][:start] = new_end - @time_slot.duration
      end
    end

    if @time_slot.update_attributes(params[:time_slot])
      if params[:wants] #AJAX (jEditable)
        respond_to do |format|
          format.js
        end
      else
        flash[:notice] = "Successfully updated timeslot."
        redirect_to @time_slot
      end
    else
      if params[:wants]
        respond_to do |format|
          format.js do
            render :text => "failed to update"
            # render :update do |page|
            #   error_string = ""
            #   @shift.errors.each do |attr_name, message|
            #     error_string += "<br>#{attr_name}: #{message}"
            #   end
            #   page << "FAIL: ";
            #   ajax_alert(page, "<strong>error:</strong> updated shift could not be saved"+error_string, 2.5 + (@shift.errors.size))
            # end
          end
        end
      else
        render :action => 'edit'
      end
      #
      # respond_to do |format|
      #   format.html{render :action => 'edit'}
      #   format.js do
      #     render :update do |page|
      #       ajax_alert(page, "<strong>error:</strong> updated timeslot could not be saved")
      #     end
      #   end
      # end
    end
  end

  def destroy
    @time_slot = TimeSlot.find(params[:id])
    @time_slot.destroy
    respond_to do |format|
      format.html {flash[:notice] = "Successfully destroyed timeslot."; redirect_to time_slots_url}
      format.js #remove partial from view
    end
  end

  def rerender
    #@period_start = params[:date] ? Date.parse(params[:date]) : Date.today.end_of_week-1.week
    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    #@block_length = current_department.department_config.time_increment
    #@blocks_per_hour = 60/@block_length.to_f
    #@blocks_per_day = @hours_per_day * @blocks_per_hour
    #@hidden_timeslots = [] #for timeslots that don't show up on the view
    @time_slot = TimeSlot.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
end
