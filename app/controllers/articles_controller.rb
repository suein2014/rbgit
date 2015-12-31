class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all
  end
  
  def admin
    @articles = Article.order("id DESC")
  end  
  
 
  def weibo_good_users
    weibo_users_file="#{ @@defaultFileDir}weibo_good_users.txt"
    file_line2array(weibo_users_file)
  end
  
  
  def wechat_good_users
    wechat_users_file="#{ @@defaultFileDir}wechat_good_users.txt"
    file_line2array(wechat_users_file)
  end
  
  private def file_line2array(file_name)
    arr= File.open(file_name,'r')
    res = Array.new
    arr.each do |line|
      res.push(line.strip())
    end
    res
  end
 
 

  def test
    filename="wechat_kol_top_by_total.txt"
    topfile = get_file_full_path(filename)
   
    if params[:category_id]
       category_info = Category.where('`id`= ? ',params[:category_id])
       if (category_info[0])
         @category_name = category_info[0].name
       end 
    end
    
    if @category_name.nil?
      params[:category_id] = 3
      @category_name = 'education'
    end
   
   
    
    @arr = file_line2array(topfile)
    #@kollist = Hash.new
    @kollist = Array.new
    
    @arr.each do |line|
      tmp = line.strip().split(",",2)
      type = tmp[0].strip()
      if type == @category_name
        kols = tmp[1].strip().split("|")
        #res_hash = Array.new
        kols.each do |s|
          tmp = s.strip().split(":")
          tmp_hash = {'name'=>tmp[0],'id'=>tmp[1],'score'=>tmp[2].to_s}
          #res_hash.push tmp_hash
          @kollist.push tmp_hash
        end
        #@kollist[@category_name] = res_hash
        
      end
    end

    #if params["export_csv"]=='1'
      time = Time.new.strftime("%Y%m%d%H") 
      @c = build_csv(@kollist)
      @filename = "#{@category_name}_#{time}.csv"
      
      respond_to do |format|
        format.html
        format.csv { send_data build_csv(@kollist), filename:filename }
      end
      #end

  end
  
  def build_csv(arr)
    csv_output=CSV.generate(:col_sep => "\t", :row_sep => "\r\n") do |csv|
      csv << ['name','wechat_id']
      arr.each do |a|
        csv <<[ a['name'],a['id'] ]
      end
    end
  end
  

  # GET /articles/1
  # GET /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
    
  end
  
  
  def spidermap
    
  end
  
  
  
  #GET /articles/top
  def top
    filename="wechat_kol_top_by_total.txt"
    topfile = get_file_full_path(filename)
    
    @kolApiIp = @@serverIp
   
    if params[:category_id]
       category_info = Category.where('`id`= ? ',params[:category_id])
       if (category_info[0])
         @category_name = category_info[0].name
       end 
    end
    
    if @category_name.nil?
      params[:category_id] = 3
      @category_name = 'education'
    end
   
   
    
    @arr = file_line2array(topfile)
    #@kollist = Hash.new
    @kollist = Array.new
    
    @arr.each do |line|
      tmp = line.strip().split(",",2)
      type = tmp[0].strip()
      if type == @category_name
        kols = tmp[1].strip().split("|")
        #res_hash = Array.new
        kols.each do |s|
          tmp = s.strip().split(":")
          tmp_hash = {'name'=>tmp[0],'id'=>tmp[1],'score'=>tmp[2].to_s}
          #res_hash.push tmp_hash
          @kollist.push tmp_hash
        end
        #@kollist[@category_name] = res_hash
        
      end
    end
    
  end
  
  
  #GET /articles/topwb
  def topwb
    filename="weibo_kol_top_by_total.txt"
    topfile = get_file_full_path(filename)
   
    if params[:category_id]
       category_info = Category.where('`id`= ? ',params[:category_id])
       if (category_info[0])
         @category_name = category_info[0].name
       end 
    end
    
    if @category_name.nil?
      params[:category_id] = 3
      @category_name = 'education'
    end
   
   
    
    @arr = file_line2array(topfile)
    #@kollist = Hash.new
    @kollist = Array.new
    
    @arr.each do |line|
      tmp = line.strip().split(",",2)
      type = tmp[0].strip()
      if type == @category_name
        kols = tmp[1].strip().split("|")
        #res_hash = Array.new
        kols.each do |s|
          tmp = s.strip().split(":")
          tmp_hash = {'name'=>tmp[0],'id'=>tmp[1],'score'=>tmp[2].to_s}
          #res_hash.push tmp_hash
          @kollist.push tmp_hash
        end
        #@kollist[@category_name] = res_hash
        
      end
    end
    
  end
  
  
  private def get_file_full_path(filename)
    filedir= @@defaultFileDir
    res = filedir + filename
  end
  
  
  
  
######################################    查看Score   begin ######################################
  #GET /articles/score?wechat_id=
  #GET /articles/score?uid=
  def score
    if params[:id]
      if params[:type] == 'weibo'
        @scores_by_id = get_type_score_by_id_from_cache(params[:id], 'weibo')
      elsif params[:type] == 'wechat'
        @scores_by_id = get_type_score_by_id_from_cache(params[:id], 'wechat')       
      end
    end
  end
  
  #for api
  def get_score
    if params[:id] && params[:type]
      @scores_by_id = get_type_score_by_id_from_cache(params[:id], params[:type])
      render json: @scores_by_id
    end
  end

  private def get_type_score_by_id_from_cache(id,type)
    key = "score_#{id}"
    res = Rails.cache.read(key)
    if res.nil?
      case type
      when "weibo"
        res = get_weibo_score_from_file(id)
      when "wechat"
        res = get_wechat_score_from_file(id)
      end
    end
    res
  end

  private def get_weibo_score_from_file(uid)
      weibo_score_file="#{ @@defaultFileDir}weibo_score.txt"
      get_score_by_id_from_file(weibo_score_file,uid)
  end

  private def get_wechat_score_from_file(wechat_id)
      wechat_score_file="#{ @@defaultFileDir}wechat_score.txt"
      get_score_by_id_from_file(wechat_score_file,wechat_id)
  end
  
  private def get_score_by_id_from_file(fine_name,id)
    ret = get_score_from_file(fine_name,id)
    res = ret[id]
    unless res.nil? 
        mc_key_id="score_#{id}"
        Rails.cache.write(mc_key_id,res) 
    end
    res
  end
 
  #id :  uid, wechat_id
  private def get_score_from_file(file_name,id)
    arr= File.open(file_name,'r')
    res = Hash.new
    arr.each do |line|
      tmp = line.strip().split("|",2)
      user_id = tmp[0]
      #mc_key_id="score_#{id}"
      #res[id] = Rails.cache.read(mc_key_id)
      if id && user_id == id
        res_hash = Hash.new
        scores = tmp[1].strip().split("|")
        scores.each do |s|
          tmp = s.strip().split("=")
          tmp_hash = {tmp[0]=>tmp[1].to_f.round(4).to_s}
          res_hash = res_hash.merge tmp_hash
        end
        res[id] = res_hash
        break # if find then can break
        #Rails.cache.write(mc_key_id,res[id]) #will spend much time if the file is large
      end
    end
    res
  end
######################################    查看Score   end ######################################
  
  
  
  def list

    @arr_weibo  = weibo_good_users
    @arr_wechat = wechat_good_users
    
    @kolApiIp = @@serverIp
    
    
    if(params[:article_id])
      article = Article.find(params[:article_id])
      if(article )
        params[:input] = article[:content]
        params[:keyword] = article[:keyword]
        category = Category.find(article[:category_id])
        params[:label] = category[:name]
      end
    end
    
    #params[:input] = 'car' if params[:input].nil?
    @input = params[:input]
    params[:keyword] = ' ' if params[:keyword].nil?
    params[:label] = '' if params[:label].nil?
    params[:type] = 'P' if params[:type].nil?
    kolURI = "http://#{@@apiIp}:8080/robin8/kol.jsp"
    uri = URI.parse(kolURI)
    res = Net::HTTP.post_form(uri,params)
    @text = ActiveSupport::JSON.decode(res.body)
    @info = @text[params["type"]]
  end

  def find
    #@articles = Article.order("id DESC")
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
      categoryURI = "http://#{@@apiIp}:8080/robin8/label.jsp"
      uri = URI.parse(categoryURI)
      res = Net::HTTP.post_form(uri,myParams)
      category = ActiveSupport::JSON.decode(res.body)
      unless category['category'].nil?
         category_info = Category.where('`name`= ? ',category['category'])
         if (category_info[0])
           params[:article][:category_id] = category_info[0].id
         end 
      end
      
      params[:article][:category_id] = 14 unless params[:article].has_key?(:category_id)

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
        unless params[:category_id].nil?
           category_id = params[:category_id]
        else params[:article][:category_id].nil?
           category_id = params[:article][:category_id]
        end
        category = Category.find(category_id)
        params['article']['category'] = category[:name]
        
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
