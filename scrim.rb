#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'httpclient'

require 'cgi'

url = "http://scr.im/test"
found = false

clnt = HTTPClient.new("http://localhost:8888")

while (not found) do

    captcha_value = "";

    q_doc = Hpricot(clnt.get(url).content)

    q_doc.search("//script").each do |x|
        if (x.html =~ /var caps = ([^;]+);/)
            caps = $1;
            puts caps;
            captcha_value = [];
            caps.scan(/"[^"]*"/) { |x| captcha_value.push(CGI.unescape(x[1..-2])); }
            captcha_value = captcha_value[rand(captcha_value.size)];
        end
    end

    if (captcha_value)
        req_params = {};

        req_params[:token] = q_doc.at("//input[@name='token']")[:value];
        req_params[:action] = "view";
        req_params[:captcha] = captcha_value;
        req_params[:ajax] = "y";

        puts req_params;

        a_doc = Hpricot(clnt.post("http://scr.im/test", req_params).content);

        if (a_doc.search("//p[@id='reveal_mail']").size > 0)
            found = true;
            puts CGI.unescapeHTML(((a_doc/"#reveal_mail")/"a").inner_html);
        end
    end

end
