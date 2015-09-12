class TelephonesController < ApplicationController
  protect_from_forgery except: :record
  
  def index
    #データベースから保存した音声データを取得してViewに渡してください！
  end

  def call
    account_sid = 'ご自身のアカウント！'
    auth_token = 'アカウントのトークン！'
    
    tel = params[:tel]
    tel.gsub!(/^0/, '+81')

    client = Twilio::REST::Client.new account_sid, auth_token
    client.calls.create(
      from: '+815031597307',
      to: tel,
      url: record_url
    ) 
    redirect_to telephones_path
    
  end

  def record
    response = ""
    if params['RecordingUrl'].present?
      response = Twilio::TwiML::Response.new do |r|
        Recording.create!(url: params['RecordingUrl'])
        r.Say 'メッセージを再生して保存します', voice: 'alice', language: 'ja-jp'
        r.Play params['RecordingUrl']
      end
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Say '録音を開始します。終わりましたらシャープを押してください', voice: 'alice', language: 'ja-jp'
        r.Record maxLength: '30', action: record_url, method: 'post', finishOnKey: '#'
      end
    end
    render text: response.text
  end

end
