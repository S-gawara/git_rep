#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require "socket"
require "rubygems"
require "nokogiri"
require "twitter"

CONSUMER_KEY = "***"
CONSUMER_SECRET = "***"
ACCESS_TOEKN = "***"
ACCESS_TOEKN_SECRET = "***"

# 認証
def twit(s)
agent = Twitter::REST::Client.new do |config|
   config.consumer_key        = CONSUMER_KEY
   config.consumer_secret     = CONSUMER_SECRET
   config.access_token        = ACCESS_TOEKN
   config.access_token_secret = ACCESS_TOEKN_SECRET
end
agent.update(s)
end

#juliusに接続
s = nil
until s
  begin
    s = TCPSocket.open("localhost", 10500)
  rescue
    STDERR.puts "Julius に接続失敗しました\n再接続を試みます"
    sleep 10
    retry
  end
end
puts "Julius に接続しました"


source = ""
while true
  ret = IO::select([s])
  ret[0].each do |sock|
    source += sock.recv(65535)
    if source[-2..source.size] == ".\n"
      source.gsub!(/\.\n/, "")
      xml = Nokogiri(source)
      words = (xml/"RECOGOUT"/"SHYPO"/"WHYPO").inject("") {|ws, w| ws + w["WORD"] }
      unless words == ""
        twit(words)
        puts "「#{words}」をツイートしました."
      end
      source = ""
    end
  end
end
