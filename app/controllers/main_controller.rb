# encoding: utf-8

class MainController < ApplicationController
  def overview
    return redirect_to main_hitme_url + '#hide-options' if signed_in?
  end

  def hitme
    fresh_when(etag: etag)
  end

  def help
    fresh_when(etag: etag)
  end

  def feedback
    fresh_when(etag: etag)
  end

  def feedback_send
    @name = params[:name]
    @mail = params[:mail]
    @text = params[:text]

    if @text.empty?
      flash[:warning] = "Ohne Text kein Feedback. Ohne Feedback KeKs schlecht. Gib uns Text, bitte!"
      return render :feedback
    end

    if UserMailer.feedback(@text, @name, @mail).deliver
      flash[:success] = "Mail ist raus, vielen Dank!"
      return redirect_to feedback_path
    else
      flash[:error] = "Das System ist kaputt. Kannst Du das bitte ganz klassisch an keks@uni-hd.de senden?"
      return render :feedback
    end
  end

  # renders json suitable for the hitme page containing only a single
  # question given
  def single_question
    render json: [json_for_question(Question.find(params[:id]))]
  end

  def questions
    # never cache this resource to ensure users get random questions
    expires_now

    time = Time.now

    cats = if params[:categories]
      params[:categories].split("_").map { |c| c.to_i }
    else
      Category.root_categories.pluck(:id)
    end

    return render :json => {error: "No categories given"} if cats.empty?

    cnt = params[:count].to_i
    return render :json => {error: "No count given"} if cnt <= 0 || cnt > 100

    diff = difficulties_from_param
    sp = study_path_ids_from_param

    question_ids = Question.where(
      :parent_type => "Category",
      :parent_id => cats,
      :difficulty => diff,
      :released => true,
      :study_path => sp)
      .pluck(:id)

    ## comment in to only show matrix-questions
    #qs.reject!{ |q| !q.matrix_validate? }

    logger.info "### get question ids: #{(Time.now - time)*1000}ms"
    time = Time.now


    qs = get_question_sample(question_ids, cnt)

    logger.info "### find sample: #{(Time.now - time)*1000}ms"
    time = Time.now

    json = qs.map.with_index do |q, idx|
      # maximum depth of 5 questions. However, avoid going to deep for
      # later questions. For example, the last question never will
      # present a subquestion, regardless if it has one. Therefore, no
      # need to query for them.
      c = cnt - idx - 1
      tmp = json_for_question(q, c < 5 ? c : 5)

      # assert the generated data looks reasonable, otherwise skip it
      unless tmp.is_a?(Hash)
        msg = "JSON for Question #{q.id} returned an array when it should be a Hash\n\n#{PP.pp(q, "")}"
        if Rails.env.production?
          logger.error msg
          next
        else
          raise msg
        end
      end

      tmp
    end

    render json: json

    logger.info "### resolve: #{(Time.now - time)*1000}ms"
    time = Time.now
  end

  def random_xkcd
    url = nil
    err = nil
    begin
      open("http://dynamic.xkcd.com/random/comic/", redirect: false) do
        url = resp.base_uri
      end
    rescue OpenURI::HTTPRedirect => rdr
      url = rdr.uri.to_s
    rescue => e
      err = e.message
    ensure
      if url
        id = url.gsub(/[^0-9]/, "")
        return redirect_to specific_xkcd_path(id)
      end

      err = "Der XKCD Server ist gerade nicht erreichbar. Sorry. Details: (random)  #{err}"
      return render(status: 502, text: err)
    end
  end

  caches_page :specific_xkcd
  def specific_xkcd
    id = params[:id].gsub(/[^0-9]/, "")
    return render(status: 400, text: "invalid id") if id.blank?

    begin
      html = open("http://xkcd.com/#{id}/").read

      comic_only = Nokogiri::HTML(html).at_css("#comic").to_s
      comic_only.gsub!("http://", "https://")
      render :text => comic_only
    rescue => e
      # TODO: this will be cached and there are no sweepers to remove it
      render :text => "Der XKCD Server ist gerade nicht erreichbar. Sorry. Details: (specific) #{e.message}"
    end
  end
end
