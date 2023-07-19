---
title: index.jsp
date: 2020-4-13
updated: 2020-4-14
tags:
  - mdphp
categories:
  - file
abbrlink: 6c70013b
---
```jsp
<%@ page contentType="text/html; charset=GBK" %>
<%@ page import="java.util.*" %>
<html><head><title>Cluster App Test</title></head>
date: 2020-4-13
updated: 2020-4-14
<body>
Server Info:
<%
out.println(request.getLocalAddr() + " : " + request.getLocalPort()+"<br>");%>
<%
out.println("<br> ID " + session.getId()+"<br>");
String dataName = request.getParameter("dataName");
if (dataName != null && dataName.length() > 0) {
String dataValue = request.getParameter("dataValue");
session.setAttribute(dataName, dataValue);
}
out.print("<b>Session list</b>");
Enumeration e = session.getAttributeNames();
while (e.hasMoreElements()) {
String name = (String)e.nextElement();
String value = session.getAttribute(name).toString();
out.println( name + " = " + value+"<br>");
System.out.println( name + " = " + value);
}
%>
<form action="test.jsp" method="POST">
name:<input type=text size=20 name="dataName">
<br>
key:<input type=text size=20 name="dataValue">
<br>
<input type=submit>
</form>
</body>
</html>
```
