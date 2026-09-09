<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR", "INMOBILIARIA", "CLIENTE"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Panel | Raíz</title>
<link rel="stylesheet" href="css/style.css"></head>
<body style="padding:40px;font-family:sans-serif">
  <p>Bienvenido, <%= esc(nombreSesion) %>
     — rol activo: <b><%= rolSesion %></b></p>
  <p><a href="logout.jsp">Cerrar sesión</a></p>
  <p><small>Panel temporal — se reemplaza en el paso 7 por dashboards reales por rol.</small></p>
</body>
</html>