<%--
  inicio.jsp - Despachador: manda a cada usuario a su panel segun su rol
  principal guardado en sesion. No genera HTML propio.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("idUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rol = (String) session.getAttribute("rol");
    if ("ADMINISTRADOR".equals(rol)) {
        response.sendRedirect("admin/panel.jsp");
    } else if ("INMOBILIARIA".equals(rol)) {
        response.sendRedirect("inmobiliaria/panel.jsp");
    } else {
        response.sendRedirect("cliente/panel.jsp");
    }
%>