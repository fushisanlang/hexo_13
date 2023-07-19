---
title: tomcat_logstash.conf
date: 2016-10-5
updated: 2016-10-6
tags:
  - logstash
categories:
  - file
abbrlink: 91116fcd
---

input {  
 file {  
  path => "/usr/local/tomcat/logs/localhost_access_log*.txt"  
  type => "apache_access_log"
  add_field => {"tomcatip" => "192.168.6.133"}
 }  
}
filter{ 
 if [type] == "apache_access_log" {
  grok{
   match => { "message" => "%{IPORHOST:clientip} %
{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"(?:%{WORD:verb} %
{URIPATHPARAM:request}(?: HTTP/%{NUMBER:httpversion})?|-)\" %{NUMBER:response} 
(?:%{NUMBER:bytes}|-) %{NUMBER:responsetime} \"(?:%{URI:referrer}|-)\" %
{QS:agent}" }
  }    
  date{
   match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
   target => ["writetime"]
  }  
  mutate {
   convert => { 
    "response" => "integer" 
    "bytes" => "integer" 
    "responsetime" => "integer" 
   }
  }
 }
}
output {
 if [type] == "apache_access_log" {  
  elasticsearch {
   hosts => ["192.168.6.133:9200"]
   index => "logstash-apacheaccesslog-%{+YYYY.MM.dd}"
  }  
 }
}