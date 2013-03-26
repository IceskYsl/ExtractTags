# coding: utf-8
require 'rubygems'
require 'rmmseg'
require 'tf_idf'
require 'net/http'
require 'open-uri'

class ExtractTags
 ALL_TOTAL = 100000000.0 
 test_strs =<<END
 大家应该注意到了，eoe启动了新一轮的工作机会，其中新增的有产品经理的岗位
 http://my.eoe.cn/eoe/page/job.html，在产品经理的JD中我说到了“极简主义者”，我这里想说说什么是极简主义产品经理，我的理解中极简主义是一种风格，倡导的是用更加优雅的方式解决现实中的问题，产品也是一样。

 做产品的人会有一个‘职业病’把任何对象都可以抽象为一个‘产品’，比如一个网站，一个app，一个卖煎饼果子的小铺，甚至一份简历，再甚至我自己这个人，而这其中无处不透露这个产品经理的品味和风格。

 拿简历来说，我特别不喜欢word格式的简历，原因有2个：
 1. word不是通用标准
 很多机器上会样式变形或者根本打不开（我收到3个简历有2个是word版我都打不开，我只能发给同事打开截图我看），至少给我一个PDF还可以接受，或者给我一个图片都可以；

 2.word版占用空间大
 尽管磁盘廉价，网速加快，但是为什么不选择更小的文档格式呢，比如TXT，或者Markdown格式就更赞了。

 一名负责任的产品经理必须处处有产品经理的特质，是否能关注细节，是否能有‘产品化’思维，是否会把自己做为一个‘特殊的产品’来打造会非常关键，你是否会通过个人博客、weibo、twitter、fb，知乎，豆瓣等等链接来展示出自己与众不同的风格呢～

 如上只是我自己对这个的认知，仅供参考～
END


 # 
 #百度为您找到相关结果约100,000,000个
 RMMSeg::Dictionary.dictionaries = [[:chars, "chars.dic"],
                                    [:words, "words.dic"],
                                    [:words, "eoe.dic"]]

 # RMMSeg::Dictionary.add_dictionary(:words, "eoe.dic")                              
 RMMSeg::Dictionary.load_dictionaries

 algor = RMMSeg::Algorithm.new(test_strs)

 data = []
 tags = {}
 loop do
   tok = algor.next_token
   break if tok.nil?
   t = tok.text
   if tags.has_key?("#{t}")
     tags["#{t}"] = tags["#{t}"]  + 1
   else
     tags["#{t}"]  = 1
   end
   # data << [tok.text]
   # puts "#{tok.text} [#{tok.start}..#{tok.end}]"
 end



 tags = tags.sort {|a1,a2| a2[1]<=>a1[1]}
 total_count = tags.size

 tf_idfs = {}
 tags.each do |k,v|
   next if k.size <= 3
   break if v.to_i == 1
   link = URI.encode("http://www.baidu.com/s?wd=#{k}")
   result = Net::HTTP.get(URI.parse(link)).force_encoding('UTF-8')
   idf = 0
   if result =~ /百度为您找到相关结果约(.+?)个/
     count = $1.gsub(",","").to_i
     idf = Math.log10(ALL_TOTAL.to_f/count+1)  
     tf =  v.to_f/total_count
     tf_idf = idf * tf
     puts "#{k}:#{v} \t tf:#{tf} \t idf:#{idf}  \ttf_idf:#{tf_idf}"

     tf_idfs["#{k}"] = tf_idf

   end
 end

  tf_idfs = tf_idfs.sort {|a1,a2| a2[1]<=>a1[1]}

  puts "关键词如下" 
  tf_idfs.each do |k,v|
    puts "====#{k}:#{v}"
  end
 
  
end




 
