class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
    discogs = @product.discogs_id

    response = HTTParty.get("https://api.discogs.com/releases/#{discogs}?&key=#{discogs_api_key}&secret=#{discogs_secret_api_key}")

    @release_data = response
  end

  # GET /products/new
  def new
    @product = Product.new

    # save user query to perform api call
    query = params[:query]

    # If query is present perform api call
    if query
      discogs_api_key = ENV.fetch('DISCOGS_API_KEY')
      discogs_secret_api_key = ENV.fetch('DISCOGS_SECRET_API_KEY')

      # perform search for query and limit to vinyl
      response = HTTParty.get("https://api.discogs.com/database/search?release_title=\"#{query}\"&format=vinyl&key=#{discogs_api_key}&secret=#{discogs_secret_api_key}")

      # return results array as instance variable
      @release_data = response['results']
      # byebug
    end
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.user_id = current_user.id

    discogs_id = @product.discogs_id

    # Search discogs to retrive release title
    response = HTTParty.get("https://api.discogs.com/releases/#{discogs_id}?&key=#{discogs_api_key}&secret=#{discogs_secret_api_key}")

    @product.name = response['title']

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
      authorize @product
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:price, :postage, :record_condition, :sleeve_condition, :discogs_id, :description, :query)
    end
end
