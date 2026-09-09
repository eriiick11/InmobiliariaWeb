<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% String tituloPagina = "Mi panel"; %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
  <h1>Bienvenido, <%= esc(nombreSesion) %></h1>
  <p>Aquí vas a poder buscar propiedades, agendar citas, radicar solicitudes
     y ver tus favoritos.</p>
  <p><small>Contenido real se agrega en los pasos 9 a 11 del proyecto
     (buscador, perfil, citas/solicitudes, favoritos).</small></p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>