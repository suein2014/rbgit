class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
    
  end
  def list

    params[:input] = 'car' if params[:input].nil?
    @input = params[:input]
    params[:keyword] = ' ' if params[:keyword].nil?
    params[:label] = '' if params[:label].nil?
    params[:type] = 'P' if params[:type].nil?
    kolURI = 'http://74.71.193.8:8080/robin8/kol.jsp'
    uri = URI.parse(kolURI)
    res = Net::HTTP.post_form(uri,params)
    @text = ActiveSupport::JSON.decode(res.body)
    @info = @text[params["type"]]
  end

  def find
    @articles = Article.all

    @article = Article.new

  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
     
     @article = Article.new(article_params)

      #获取文章所属类别
      myParams = {}
      myParams[:label] = params[:article][:content]
      categoryURI = 'http://74.71.193.8:8080/robin8/label.jsp'
      uri = URI.parse(categoryURI)
      res = Net::HTTP.post_form(uri,myParams)
      params[:article][:category] = res.body #ActiveSupport::JSON.decode(res.body)
 

    respond_to do |format|
      if @article.save
        #format.html {  redirect_to :action=>'list',:title=>params['article']['title'] }
        #format.html {  render :for_redirect  }
        format.html {  render :check_category  }
        format.json { render :show, status: :created, location: @user }

      else
        format.html { redirect_to  :action =>'find' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        #format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.html {  render :for_redirect  }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :content, :keyword,:source,:category_id)
    end
end