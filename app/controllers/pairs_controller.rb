class PairsController < ApplicationController
  def index
  end

  def image_form
  end

  def upload
    return redirect_to pair_path, alert: "入力項目が空ですよ!" if params[:text].blank? || params[:image].blank?

    text_data = base64_text
    image_data = params[:image]
    sound_url = params[:sound]

    result = upload_data(text_data, sound_url, image_data)

    if result["flag"] == 'success'
      redirect_to pair_path, notice: "秘密のメッセージ「#{text_data}」と画像が送られました☆"
    else
      redirect_to pair_path, alert: "#{result["txt"]} #{result["image"]}"
    end
  end

  private
    def pair_params
      params.require(:pair).permit(:text, :image)
    end

    def base64_text
      Base64.encode64(params[:text])
    end

    def upload_data(text, sound, image)
      path = resize_image(image)
      connection = Faraday::Connection.new(url: 'http://pair.malkdesign.com/' ) do |conn|
        conn.request :multipart
        conn.adapter :net_http
      end

      params = {
        text: text,
        sound: sound, 
        picture: Faraday::UploadIO.new(path, 'image/jpg') 
      }
      res = connection.post '/check.php', params
      return JSON.parse(res.body)
    end

    def resize_image(image)
      img = Magick::Image.from_blob(image.tempfile.read).shift
      img = img.resize_to_fit(1000, 420)
      f = Tempfile.new('tmp')
      img.write(f.path)
      f.path
    end

end
