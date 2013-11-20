class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :edit, :update, :destroy]

  # GET /trips
  # GET /trips.json
  def index
    @trips = Trip.all
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    @station = Station.all
  end

  # GET /trips/new
  def new
    @trip = Trip.new
  end

  # GET /trips/1/edit
  def edit
  end

  # POST /trips
  # POST /trips.json
  def create
    @origin = Origin.new(:address => trip_params[:origin][:address].concat(" NYC"))
    @origin.save
    @destination = Destination.new(:address => trip_params[:destination][:address].concat(" NYC"))
    @destination.save
    @trip = Trip.new(:origin_id => @origin.id, :destination_id => @destination.id)
    @trip.save

    respond_to do |format|
      if @trip.save
        format.html { redirect_to @trip, notice: 'Trip was successfully created.' }
        format.json { render action: 'show', status: :created, location: @trip }
      else
        format.html { render action: 'new' }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
    @trip.origin.update(trip_params[:origin])
    @trip.destination.update(trip_params[:destination])


    
    # def update
    #   respond_to do |format|
    #     if @trip.update(trip_params)
    #       format.html { redirect_to @trip, notice: 'Trip was successfully updated.' }
    #       format.json { head :no_content }
    #     else
    #       format.html { render action: 'edit' }
    #       format.json { render json: @trip.errors, status: :unprocessable_entity }
    #     end
    #   end
    # end
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    @trip.destroy
    respond_to do |format|
      format.html { redirect_to trips_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trip_params
      params.require(:trip).permit(:origin =>[:address, :station_id], :destination => [:address,:station_id])
    end
end
