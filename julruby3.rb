#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

require "socket"
require "rubygems"
require "nokogiri"

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

# 辞書
dict = ["デジタル", "データ", "デジタル化", "数字", "映像", "コンピュータ", "情報", "情報化","ワープロ", "アナログ", "共通", "表す", "処理", "数値化", "暗号", "圧縮", "音楽", "画像", "動画"]

while true
    ret = IO::select([s])
    ret[0].each do |sock|
        source += sock.recv(65535)
        if source[-2..source.size] == ".\n"
        source.gsub!(/\.\n/, "")
        xml = Nokogiri(source)
        words = (xml/"RECOGOUT"/"SHYPO"/"WHYPO").inject("") {|ws, w| ws + w["WORD"]} 

        # 文章の表示
        unless words == ""
            # puts "#{words}"
        end

       # 取得単語の表示
       # (xml/"RECOGOUT"/"SHYPO"/"WHYPO").each do |key|
       #    print "登録した単語："
       #    dict.each do |dictword|
               # puts dictword + "," if key["WORD"] =~ /#{dictword}/
       #       dict = dict - dictword if key["WORD"] =~ /#{dictword}/
       #       puts dict
       #    end
       # print "\n"
       # end

       (xml/"RECOGOUT"/"SHYPO"/"WHYPO").each do |key|
	   dict.each do |dictword|
               puts "取得単語： " + dictword if key["WORD"] =~ /#{dictword}/
	       print "\n"
	   end
           puts "不足単語： "
	   dict = dict - [key["WORD"]]
	   puts dict
	   print "\n"
       end
        source = ""
        end
    end
end
