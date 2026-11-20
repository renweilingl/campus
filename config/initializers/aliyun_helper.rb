class AliyunOss
  CarrierWave.configure do |config|
    config.storage           = :aliyun
    config.aliyun_access_id  = ENV["ALIYUN_ACCESS_KEY_ID"]
    config.aliyun_access_key = ENV["ALIYUN_ACCESS_KEY_SECRET"]
    config.aliyun_bucket     = ENV["ALIYUN_OSS_BUCKET"]
    # 内网 endpoint（oss-*-internal）只在阿里云机房内可解析；只有显式配 "true" 才走内网，
    # 本机开发配 false 或不配都必须走公网域名，否则 getaddrinfo 解析失败
    config.aliyun_internal   = ENV["ALIYUN_OSS_INTERNAL"] == "true"
    # 空字符串在 Ruby 里是 truthy，会让 carrierwave-aliyun 拼出 "oss-.aliyuncs.com" 这种坏域名；
    # 没配 ENDPOINT 时置 nil，走 gem 的 cn-hangzhou 默认区域
    config.aliyun_area       = ENV["ALIYUN_OSS_ENDPOINT"].to_s.sub(/^oss-/, "").sub(/\.aliyuncs\.com$/, "").presence
  end

  @uploader = CarrierWave::Uploader::Base.new
  @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)

  def self.instance
    @bucket
  end
end
